resource "kubernetes_namespace" "nginx" {
  metadata {
    name = "nginx"
  }
}

resource "kubernetes_deployment" "nginx" {
  metadata {
    name = "nginx"
    labels = {
      instance = "nginx"
    }
    namespace = element(kubernetes_namespace.nginx.metadata, 0).name
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
        namespace = element(kubernetes_namespace.nginx.metadata, 0).name
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

resource "helm_release" "nginx_ingress" {
  name       = "nginx"
  chart      = "${path.module}/charts/ingress-services"
  values = [
    templatefile("${path.module}/templates/ingress-values.yaml.tpl", {
      namespace = element(kubernetes_namespace.nginx.metadata, 0).name
      service_name = element(kubernetes_service.nginx.metadata, 0).name
      service_port = kubernetes_service.nginx.spec.0.port.0.port
      prefixes = ["/nginx", "/webserver"]
      strip_prefixes = ["/nginx", "/webserver"]
      hosts = ["localhost", "localhost.localdomain"]
    })
  ]
  depends_on = [
    kubernetes_service.nginx
  ]
}
