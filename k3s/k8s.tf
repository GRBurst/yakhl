resource "kubernetes_namespace" "pluto" {
  metadata {
    name = "pluto"
  }
}

resource "kubernetes_deployment" "nginx" {
  metadata {
    name = "nginx"
    labels = {
      instance = "pluto"
    }
    namespace = element(kubernetes_namespace.pluto.metadata, 0).name
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        env = "local"
      }
    }

    template {
      metadata {
        labels = {
          env = "local"
          app = "nginx"
        }
      }


      spec {
        container {
          image = "nginx:1.21.6"
          name  = "nginx"

          port {
            name = "http"
            container_port = 80
          }
          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "nginx" {
    metadata {
        name = "nginx"
        namespace = element(kubernetes_namespace.pluto.metadata, 0).name
    }
    spec {
        selector = {
            app = element(element(element(kubernetes_deployment.nginx.spec, 0).template, 0).metadata, 0).labels.app
        }
        port {
            port = 80
            target_port = "http"
        }
    }
  depends_on = [
    kubernetes_deployment.nginx
  ]
}

resource "kubernetes_manifest" "nginx_middleware" {
 manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "Middleware"
    metadata = {
      name = "nginx"
      namespace = element(kubernetes_namespace.pluto.metadata, 0).name
    }
    spec = {
      stripPrefix = {
        forceSlash = false
        prefixes = [
          "/nginx",
          "/web",
        ]
      }
    }
  }
}

resource "kubernetes_ingress_v1" "default" {
  metadata {
    name = "default"
    namespace = element(kubernetes_namespace.pluto.metadata, 0).name
    annotations = {
      "traefik.ingress.kubernetes.io/router.middlewares"      = "pluto-nginx@kubernetescrd"
    }
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

# Use ingress rules to route traffic to nginx
# For clarification: It uses default traffic lb, not nginx
resource "kubernetes_ingress_v1" "nginx" {
  metadata {
    name = "nginx"
    namespace = element(kubernetes_namespace.pluto.metadata, 0).name
    annotations = {
      "traefik.ingress.kubernetes.io/router.middlewares"      = "pluto-nginx@kubernetescrd"
    }
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

    rule {
      http {
        path {
          path_type = "Prefix"
          path = "/nginx"
          backend {
            service {
              name = kubernetes_service.nginx.metadata.0.name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}

# Display load balancer hostname (typically present in AWS)
output "load_balancer_hostname" {
  value = kubernetes_ingress_v1.nginx.status.0.load_balancer.0.ingress.0.hostname
}

# Display load balancer IP (typically present in GCP, or using Nginx ingress controller)
output "load_balancer_ip" {
  value = kubernetes_ingress_v1.nginx.status.0.load_balancer.0.ingress.0.ip
}
