# helm repo add traefik-mesh https://helm.traefik-mesh.io/mesh

locals {
  traefik-mesh = {
    name           = "traefik-mesh"
  }
}

resource "kubernetes_namespace" "traefik_mesh" {
  metadata {
    name = local.traefik-mesh.name
  }
}

resource "helm_release" "traefik_mesh" {
  namespace  = kubernetes_namespace.traefik_mesh.metadata.0.name
  name       = local.traefik-mesh.name
  repository = "https://traefik.github.io/charts"
  chart      = "traefik-mesh"
  version    = "4.1.1"
}
