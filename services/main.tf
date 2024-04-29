resource "kubernetes_namespace" "pluto" {
  metadata {
    name = "pluto"
  }
}

data "kubernetes_service" "k3s_traefik" {
  metadata {
    name = "traefik"
    namespace = "kube-system"
  }
}

output "k3s_traefik_service" {
  value = data.kubernetes_service.k3s_traefik.spec[0].cluster_ip
}
