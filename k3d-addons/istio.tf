# # helm repo add istio https://istio-release.storage.googleapis.com/charts
# locals {
#   istio = {
#     name           = "istio"
#     data           = "${local.defaults.root}/istio/data"
#     backup         = "${local.defaults.root}/istio/backup"
#     config_volume  = "config"
#   }
# }

# resource "kubernetes_namespace" "istio" {
#   metadata {
#     name = "${local.istio.name}-system"
#   }
# }

# resource "helm_release" "istio" {
#   namespace  = kubernetes_namespace.istio.metadata.0.name
#   name       = local.istio.name
#   repository = "https://istio-release.storage.googleapis.com/charts"
#   chart      = "base"
#   version    = "1.21.1"
# }
