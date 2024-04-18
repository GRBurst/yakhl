locals {
  syncthing = {
    name           = "syncthing"
    config_pvc     = "syncthing-config-pvc"
    data           = "${local.defaults.storage.root}/syncthing/data"
    backup         = "${local.defaults.storage.root}/syncthing/backup"
    config_volume  = "config"
  }
}

resource "kubernetes_namespace" "syncthing" {
  metadata {
    name = local.syncthing.name
  }
}

# resource "kubernetes_persistent_volume_claim_v1" "syncthing_config" {
#   metadata {
#     name      = local.syncthing.config_pvc
#     namespace = kubernetes_namespace.syncthing.metadata.0.name
#   }
#   spec {
#     access_modes = ["ReadWriteOnce"]
#     resources {
#       requests = {
#         storage = "100Mi"
#       }
#     }
#     storage_class_name = "local-path"
#   }
# }

# resource "helm_release" "syncthing" {
#   namespace  = kubernetes_namespace.syncthing.metadata.0.name
#   name       = "syncthing"
#   repository = "https://charts.truecharts.org"
#   chart      = "syncthing"
#   version    = "18.5.2"

#   set {
#     name = "service.type"
#     value = "ClusterIP"
#   }

#   # set {
#   #   name = "persistence.data.enabled"
#   #   value = true
#   # }
#   # set {
#   #   name = "persistence.data.mountPath"
#   #   value = "/data"
#   # }

#   # set {
#   #   name = "persistence.data.size"
#   #   value = "10Gi"
#   # }


# }
