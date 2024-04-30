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

output "k3s_traefik_service_ip" {
  value = data.kubernetes_service.k3s_traefik.spec.0.cluster_ip
}

output "k3s_traefik_ingress_ip" {
  value = data.kubernetes_service.k3s_traefik.status.0.load_balancer.0.ingress.0.ip
}
