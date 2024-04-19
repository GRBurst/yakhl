locals {
  nextcloud = {
    name           = "nextcloud"
    config_pvc     = "nextcloud-config-pvc"
    data_storage   = "${local.defaults.storage.root}/nextcloud/data"
  }
}

resource "kubernetes_namespace" "nextcloud" {
  metadata {
    name = local.nextcloud.name
  }
}

resource "kubernetes_persistent_volume_claim_v1" "nextcloud_config" {
  metadata {
    name      = local.nextcloud.config_pvc
    namespace = kubernetes_namespace.nextcloud.metadata.0.name
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

resource "random_password" "nextcloud_admin_user" {
  length           = 32
  special          = true
}

resource "kubernetes_secret_v1" "nextcloud_admin_user" {
  metadata {
    namespace  = kubernetes_namespace.nextcloud.metadata.0.name
    name = "nextcloud-admin"
  }

  data = {
    username = "yoda"
    password = random_password.nextcloud_admin_user.result
  }
  wait_for_service_account_token = true
}

# resource "kubernetes_config_map_v1" "nextcloud_php_config" {
#   metadata {
#     name = "${local.nextcloud.name}-php-config"
#     namespace = kubernetes_namespace.nextcloud.metadata.0.name
#   }

#   data = {
#     "phpConf" = <<-CONF
# <?php
# $CONFIG = array (
#   'trusted_proxies'   => ['10.0.0.1'],
#   'overwritehost'     => 'cloud.localhost',
#   'overwriteprotocol' => 'https',
#   'overwrite.cli.url' => 'https://cloud.localhost/,
# );
#     CONF
#   }
# }

resource "kubernetes_deployment_v1" "nextcloud" {
  metadata {
    name      = local.nextcloud.name
    namespace = kubernetes_namespace.nextcloud.metadata.0.name
    labels = {
      app = local.nextcloud.name
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "nextcloud"
      }
    }

    template {
      metadata {
        labels = {
          app = "nextcloud"
        }
      }

      spec {
        container {
          # image = "lscr.io/linuxserver/nextcloud:amd64-28.0.4"
          # image = "nextcloud/all-in-one:20240404_082330-latest"
          image = "nextcloud:28-apache"
          name  = "nextcloud"
          port {
            name           = "http"
            container_port = 80
          }
          env {
            name = "SQLITE_DATABASE"
            value = "nextcloud"
          }
          env {
            name = "OVERWRITEPROTOCOL"
            value = "https"
          }
          env {
            name = "OVERWRITECLIURL"
            value = "https://cloud.localhost/"
          }
          env {
            name = "OVERWRITEHOST"
            value = "cloud.localhost"
          }
          env {
            name = "TRUSTED_PROXIES"
            value = "10.43.255.230 172.20.0.3" # hardcoded, need to get from cluster or setup traefik service manually
          }
          env {
            name = "NEXTCLOUD_TABLE_PREFIX"
            value = "nc_"
          }
          env {
            name = "NEXTCLOUD_TRUSTED_DOMAINS"
            value = "cloud.localhost"
          }
          env {
            name = "NEXTCLOUD_ADMIN_USER"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.nextcloud_admin_user.metadata.0.name
                key = "username"
              }
            }
          }
          env {
            name = "NEXTCLOUD_ADMIN_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.nextcloud_admin_user.metadata.0.name
                key = "password"
              }
            }
          }
          volume_mount {
            name       = "config"
            mount_path = "/config"
          }
          volume_mount {
            name       = "data"
            mount_path = "/var/www/html/data"
          }
        }
        volume {
          name = "config"
          persistent_volume_claim {
            claim_name = local.nextcloud.config_pvc
          }
        }
        volume {
          name = "data"
          host_path {
            path = local.nextcloud.data_storage
            type = "Directory"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "nextcloud" {
  metadata {
    name      = "nextcloud"
    namespace = element(kubernetes_namespace.nextcloud.metadata, 0).name
    annotations = {
      "mesh.traefik.io/traffic-type" = "http",
      "mesh.traefik.io/retry-attempts" = 2
    }
  }
  spec {
    selector = {
      app = element(element(element(kubernetes_deployment_v1.nextcloud.spec, 0).template, 0).metadata, 0).labels.app
    }
    port {
      name        = "http"
      port        = 80
    }
  }
  depends_on = [
    kubernetes_deployment_v1.nextcloud
  ]
}

# This can only be applied when the namespace is created, because 
# there is no valid OpenAPI schema for this resource
# https://github.com/hashicorp/terraform-provider-kubernetes/issues/1692
resource "kubernetes_manifest" "nextcloud_proxy_middleware" {
 manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "Middleware"
    metadata = {
      name = "nextcloud-proxy"
      namespace = kubernetes_namespace.nextcloud.metadata.0.name
    }
    spec = {
      redirectRegex = {
        permanent = true
        regex = "https://(.*)/.well-known/(?:card|cal)dav"
        replacement = "https://$${1}/remote.php/dav"
      }
    }
  }
  depends_on = [
    kubernetes_namespace.nextcloud
  ]
}

resource "helm_release" "nextcloud_ingress" {
  name       = local.nextcloud.name
  chart      = "${path.module}/charts/ingress-services"
  values = [
    templatefile("${path.module}/templates/ingress-values.yaml.tpl", merge(local.defaults.ingress, {
      namespace = kubernetes_namespace.nextcloud.metadata.0.name
      service_name = kubernetes_service.nextcloud.metadata.0.name
      service_port = kubernetes_service.nextcloud.spec.0.port.0.port
      hosts = ["cloud.localhost", "cloud.localhost.localdomain"]
      additional_ingress_middlewares = [
        "${element(kubernetes_namespace.nextcloud.metadata, 0).name}-${kubernetes_manifest.nextcloud_proxy_middleware.manifest.metadata.name}@kubernetescrd"
      ]
    }))
  ]
  depends_on = [
    kubernetes_service.nextcloud,
    kubernetes_manifest.nextcloud_proxy_middleware
  ]
}

# helm repo add nextcloud https://nextcloud.github.io/helm/
# helm install my-nextcloud nextcloud/nextcloud --version 4.6.4
# resource "helm_release" "nextcloud" {
#   namespace  = kubernetes_namespace.nextcloud.metadata.0.name
#   name       = local.nextcloud.name
#   repository = "https://nextcloud.github.io/helm/"
#   chart      = "nextcloud"
#   version    = "4.6.4"

#   set {
#     name = "ingress.enabled"
#     value = true
#   }
#   set {
#     name = "ingress.annotations.traefik\\.http\\.routers\\.nextcloud\\.middlewares"
#     value = "nextcloud_redirectregex"
#   }
#   set {
#     name = "ingress.annotations\\.traefik\\.http\\.middlewares\\.nextcloud_redirectregex\\.redirectregex\\.permanent"
#     value = true
#   }
#   set {
#     name = "ingress.annotations\\.traefik\\.http\\.middlewares\\.nextcloud_redirectregex\\.redirectregex\\.regex"
#     value = "https://(.*)/.well-known/(?:card|cal)dav"
#   }
#   set {
#     name = "ingress.annotations\\.traefik\\.http\\.middlewares\\.nextcloud_redirectregex\\.redirectregex\\.replacement"
#     value = "https://$${1}/remote.php/dav"
#   }
#   set {
#     name = "nextcloud.host"
#     value = "cloud.localhost"
#   }
#   set {
#     name = "service.type"
#     value = "ClusterIP"
#   }

#   # nextcloud.phpConfigs
# }

output "admin-user" {
  value = {
    username = kubernetes_secret_v1.nextcloud_admin_user.data.username
    password = kubernetes_secret_v1.nextcloud_admin_user.data.password
  }
  sensitive = true
}
