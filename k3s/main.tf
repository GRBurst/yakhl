resource "kubernetes_namespace" "pluto" {
  metadata {
    name = "pluto"
  }
}

resource "kubernetes_ingress_v1" "default" {
  metadata {
    name = "default"
    namespace = element(kubernetes_namespace.nginx.metadata, 0).name
  }

  spec {
    default_backend {
      service {
        name = kubernetes_service.nginx.metadata.0.name
        port {
          number = 80
        }
      }
    }
  }
}
