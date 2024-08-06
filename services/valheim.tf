locals {
  valheim = {
    name          = "valheim"
    config_pvc    = "valheim-config-pvc"
    data_storage  = "${local.defaults.storage.root}/valheim/data"
    server = {
      world_name = "Dedicated"
      server_name = "MyServer"
      server_pass = "secret"
      server_public = false
      valheim_plus = true
      valheim_plus_repo = "Grantapher/ValheimPlus"
    }
  }
}

resource "kubernetes_namespace" "valheim" {
  metadata {
    name = local.valheim.name
  }
}

resource "kubernetes_persistent_volume_claim_v1" "valheim_config" {
  metadata {
    name      = local.valheim.config_pvc
    namespace = kubernetes_namespace.valheim.metadata.0.name
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "100Mi"
      }
    }
    storage_class_name = "local-path"
  }
}

resource "kubernetes_deployment_v1" "valheim" {
  metadata {
    name      = local.valheim.name
    namespace = kubernetes_namespace.valheim.metadata.0.name
    labels = {
      app = local.valheim.name
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = local.valheim.name
      }
    }

    template {
      metadata {
        labels = {
          app = local.valheim.name
        }
      }

      spec {
        container {
          image = "ghcr.io/lloesche/valheim-server:latest"
          name  = "valheim"
          security_context {
            capabilities {
              add = [
                "SYS_NICE"
              ]
            }
          }
          port {
            name           = "server-udp"
            protocol       = "UDP"
            container_port = 2456
          }
          port {
            name           = "server-udp-alt"
            protocol       = "UDP"
            container_port = 2457
          }
          port {
            name           = "supervisor"
            container_port = 9001
          }
          env {
            name = "WORLD_NAME"
            value = local.valheim.server.world_name
          }
          env {
            name = "SERVER_NAME"
            value = local.valheim.server.server_name
          }
          env {
            name = "SERVER_PASS"
            value = local.valheim.server.server_pass
          }
          env {
            name = "SERVER_PUBLIC"
            value = local.valheim.server.server_public
          }
          env {
            name = "VALHEIM_PLUS"
            value = local.valheim.server.valheim_plus
          }
          env {
            name = "VALHEIM_PLUS_REPO"
            value = local.valheim.server.valheim_plus_repo
          }
          volume_mount {
            name       = "config"
            mount_path = "/config"
          }
          volume_mount {
            name       = "data"
            mount_path = "/opt/valheim"
          }
        }
        volume {
          name = "config"
          persistent_volume_claim {
            claim_name = local.valheim.config_pvc
          }
        }
        volume {
          name = "data"
          host_path {
            path = local.valheim.data_storage
            type = "Directory"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "valheim" {
  metadata {
    name      = "valheim"
    namespace = element(kubernetes_namespace.valheim.metadata, 0).name
    annotations = {
      "mesh.traefik.io/traffic-type" = "udp",
      "mesh.traefik.io/retry-attempts" = 2
    }
  }
  spec {
    selector = {
      app = element(element(element(kubernetes_deployment_v1.valheim.spec, 0).template, 0).metadata, 0).labels.app
    }
    port {
      protocol    = "UDP"
      name        = "server-udp"
      port        = 25575
      target_port = "server-udp"
    }
  }
  depends_on = [
    kubernetes_deployment_v1.valheim
  ]
}

resource "helm_release" "valheim_ingress" {
  name       = local.valheim.name
  chart      = "${path.module}/charts/ingress-services"
  values = [
    templatefile("${path.module}/templates/ingress-values.yaml.tpl", merge(local.defaults.ingress, {
      namespace = kubernetes_namespace.valheim.metadata.0.name
      service_name = kubernetes_service.valheim.metadata.0.name
      service_port = kubernetes_service.valheim.spec.0.port.0.port
      hosts = ["valheim.localhost", "valheim.localhost.localdomain"]
    }))
  ]
  depends_on = [
    kubernetes_service.valheim
  ]
}
