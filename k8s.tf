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
        }
    }
}
