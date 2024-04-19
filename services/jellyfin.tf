locals {
  jellyfin = {
    name          = "jellyfin"
    config_pvc    = "jellyfin-config-pvc"
    media_storage = "${local.defaults.storage.root}/jellyfin/library"
  }
}

resource "kubernetes_namespace" "jellyfin" {
  metadata {
    name = local.jellyfin.name
  }
}

# Jellyfin data storage location. This can grow very large, 50gb+ is likely for a large collection.
resource "kubernetes_persistent_volume_claim_v1" "jellyfin_config" {
  metadata {
    name      = local.jellyfin.config_pvc
    namespace = kubernetes_namespace.jellyfin.metadata.0.name
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "1Gi"
      }
    }
    storage_class_name = "local-path"
  }
}

resource "kubernetes_deployment_v1" "jellyfin" {
  metadata {
    name      = local.jellyfin.name
    namespace = kubernetes_namespace.jellyfin.metadata.0.name
    labels = {
      app = local.jellyfin.name
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = local.jellyfin.name
      }
    }

    template {
      metadata {
        labels = {
          app = local.jellyfin.name
        }
      }

      spec {
        container {
          image = "lscr.io/linuxserver/jellyfin:amd64-10.8.13"
          name  = "jellyfin"
          port {
            name           = "web"
            container_port = 8096
          }
          port {
            name           = "local-discovery"
            container_port = 7359
          }
          port {
            name           = "dlna"
            container_port = 1900
          }
          env {
            name = "JELLYFIN_PublishedServerUrl"
            value = "https://media.localhost"
          }
          volume_mount {
            name       = "config"
            mount_path = "/config"
          }
          volume_mount {
            name       = "movies"
            mount_path = "/data/movies"
          }
          volume_mount {
            name       = "shows"
            mount_path = "/data/shows"
          }
        }
        volume {
          name = "config"
          persistent_volume_claim {
            claim_name = local.jellyfin.config_pvc
          }
        }
        volume {
          name = "movies"
          host_path {
            path = "${local.jellyfin.media_storage}/movies"
            type = "Directory"
          }
        }
        volume {
          name = "shows"
          host_path {
            path = "${local.jellyfin.media_storage}/shows"
            type = "Directory"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "jellyfin_web" {
  metadata {
    name      = "jellyfin-web"
    namespace = element(kubernetes_namespace.jellyfin.metadata, 0).name
    annotations = {
      "mesh.traefik.io/traffic-type" = "http",
      "mesh.traefik.io/retry-attempts" = 2
    }
  }
  spec {
    selector = {
      app = element(element(element(kubernetes_deployment_v1.jellyfin.spec, 0).template, 0).metadata, 0).labels.app
    }
    port {
      name        = "web"
      port        = 8096
      target_port = "web"
    }
  }
  depends_on = [
    kubernetes_deployment_v1.jellyfin
  ]
}

resource "helm_release" "jellyfin_ingress" {
  name       = local.jellyfin.name
  chart      = "${path.module}/charts/ingress-services"
  values = [
    templatefile("${path.module}/templates/ingress-values.yaml.tpl", merge(local.defaults.ingress, {
      namespace = kubernetes_namespace.jellyfin.metadata.0.name
      service_name = kubernetes_service.jellyfin_web.metadata.0.name
      service_port = kubernetes_service.jellyfin_web.spec.0.port.0.port
      hosts = ["media.localhost", "media.localhost.localdomain"]
      prefixes = ["/web", "/socket", "/"]
      strip_prefixes = ["/media", "/jellyfin"]
    }))
  ]
  depends_on = [
    kubernetes_service.jellyfin_web
  ]
}

# resource "kubernetes_service" "jellyfin_discovery" {
#   metadata {
#     name      = "jellyfin-local-discovery"
#     namespace = kubernetes_namespace.jellyfin.metadata.0.name
#   }
#   spec {
#     type = "LoadBalancer"
#     selector = {
#       app = "jellyfin"
#     }
#     port {
#       name        = "local-discovery"
#       port        = 7359
#       target_port = "local-discovery"
#     }
#     port {
#       name        = "dlna"
#       port        = 1900
#       target_port = "dlna"
#     }
#   }
# }
