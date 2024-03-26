locals {
  namespace         = "jellyfin"
  jellyfin_data_pvc = "jellyfin-data-pvc"
  media_storage     = "/media/jellyfin/library"
}

resource "kubernetes_namespace" "jellyfin" {
  metadata {
    name = local.namespace
  }
}

resource "kubernetes_deployment" "jellyfin" {
  metadata {
    name      = "jellyfin"
    namespace = kubernetes_namespace.jellyfin.metadata.0.name
    labels = {
      app = "jellyfin"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "jellyfin"
      }
    }

    template {
      metadata {
        labels = {
          app = "jellyfin"
        }
      }

      spec {
        container {
          image = "lscr.io/linuxserver/jellyfin:latest"
          name  = "jellyfin"
          # env_from { # ENV File
          #   config_map_ref {
          #     name = kubernetes_config_map.jellyfin_env.metadata.0.name
          #   }
          # }
          port {
            name           = "web"
            container_port = 8096
          }
          # port {
          #   name           = "local-discovery"
          #   container_port = 7359
          # }
          # port {
          #   name           = "dlna"
          #   container_port = 1900
          # }
          volume_mount {
            name       = "data"
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
          resources {
            requests = {
              cpu = 2
            }
            limits = {
              cpu = 4
            }
          }
        }
        volume {
          name = "data"
          persistent_volume_claim {
            claim_name = local.jellyfin_data_pvc
          }
        }
        volume {
          name = "movies"
          host_path {
            path = "${local.media_storage}/movies"
            type = "Directory"
          }
        }
        volume {
          name = "shows"
          host_path {
            path = "${local.media_storage}/shows"
            type = "Directory"
          }
        }
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "jellyfin_data" {
  metadata {
    name      = local.jellyfin_data_pvc
    namespace = kubernetes_namespace.jellyfin.metadata.0.name
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "15Gi"
      }
    }
    storage_class_name = "local-path"
  }
}

resource "kubernetes_service" "jellyfin_web" {
  metadata {
    name      = "jellyfin-web"
    namespace = element(kubernetes_namespace.jellyfin.metadata, 0).name
  }
  spec {
    selector = {
      app = element(element(element(kubernetes_deployment.jellyfin.spec, 0).template, 0).metadata, 0).labels.app
    }
    port {
      name        = "web"
      port        = 8096
      target_port = "web"
    }
  }
  depends_on = [
    kubernetes_deployment.jellyfin
  ]
}


resource "kubernetes_manifest" "jellyfin_middleware" {
 manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "Middleware"
    metadata = {
      name = "jellyfin"
      namespace = element(kubernetes_namespace.jellyfin.metadata, 0).name
    }
    spec = {
      stripPrefix = {
        forceSlash = false
        prefixes = [
          "/media",
          "/jellyfin",
        ]
      }
    }
  }
}

resource "kubernetes_ingress_v1" "jellyfin" {
  metadata {
    name = "jellyfin"
    namespace = element(kubernetes_namespace.jellyfin.metadata, 0).name
    annotations = {
      "traefik.ingress.kubernetes.io/router.middlewares"      = "jellyfin-jellyfin@kubernetescrd" # <middleware-namespace>-<middleware-name>@kubernetescrd
    }
  }

  spec {
    rule {
      # Trailing wildcards are not supported
      # https://github.com/kubernetes/kubernetes/issues/41881
      # host = "media.*"
      http {
        path {
          path_type = "Prefix"
          path = "/media"
          backend {
            service {
              name = kubernetes_service.jellyfin_web.metadata.0.name
              port {
                name = "web"
              }
            }
          }
        }
        path {
          path_type = "Prefix"
          path = "/web/"
          backend {
            service {
              name = kubernetes_service.jellyfin_web.metadata.0.name
              port {
                name = "web"
              }
            }
          }
        }
      }
    }
  }
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
