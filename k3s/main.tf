resource "kubernetes_namespace" "pluto" {
  metadata {
    name = "pluto"
  }
}
