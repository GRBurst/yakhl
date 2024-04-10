locals {
  nextcloud = {
    name           = "nextcloud"
    data           = "${local.defaults.root}/nextcloud/data"
    backup         = "${local.defaults.root}/nextcloud/backup"
    config_volume  = "config"
  }
}

resource "kubernetes_namespace" "nextcloud" {
  metadata {
    name = local.nextcloud.name
  }
}

# resource "kubernetes_persistent_volume_claim" "config" {
#   metadata {
#     name      = local.nextcloud.name
#     namespace = local.nextcloud.name
#   }
#   spec {
#     annotations = [
#       volumeType = "hostPath"
#     ]
#     access_modes = ["ReadWriteOnce"]
#     resources {
#       requests = {
#         storage = "100Mi"
#       }
#     }
#     storage_class_name = "local-path"
#   }
# }

# helm repo add nextcloud https://nextcloud.github.io/helm/
# helm install my-nextcloud nextcloud/nextcloud --version 4.6.4
resource "helm_release" "nextcloud" {
  namespace  = kubernetes_namespace.nextcloud.metadata.0.name
  name       = local.nextcloud.name
  repository = "https://nextcloud.github.io/helm/"
  chart      = "nextcloud"
  version    = "4.6.4"

  set {
    name = "ingress.enabled"
    value = true
  }
  set {
    name = "nextcloud.host"
    value = "cloud.localhost"
  }
  set {
    name = "service.type"
    value = "ClusterIP"
  }

  # nextcloud.phpConfigs
}

# resource "helm_release" "nextcloud_ingress" {
#   name       = kubernetes_namespace.nextcloud.metadata.0.name
#   chart      = "./charts/ingress-services"
#   values = [
#     templatefile("${path.module}/ingress-values.yaml.tpl", {
#       namespace = kubernetes_namespace.nextcloud.metadata.0.name
#       service_name = "nextcloud" #helm_release.nextcloud.metadata.0.name
#       service_port = 8080
#       prefixes = ["/nextcloud"]
#       strip_prefixes = ["/nextcloud"]
#       hosts = ["localhost", "localhost.localdomain"]
#     })
#   ]
#   depends_on = [
#     helm_release.nextcloud
#   ]
# }
