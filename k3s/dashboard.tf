locals {
  dashboard = {
    name           = "kubernetes-dashboard"
  }
}

resource "kubernetes_namespace" "dashboard" {
  metadata {
    name = local.dashboard.name
  }
}

resource "kubernetes_service_account" "dashboard" {
  metadata {
    namespace  = kubernetes_namespace.dashboard.metadata.0.name
    name = "admin"
  }
}

resource "kubernetes_secret" "dashboard" {
  metadata {
    namespace  = kubernetes_namespace.dashboard.metadata.0.name
    annotations = {
      "kubernetes.io/service-account.name" = kubernetes_service_account.dashboard.metadata.0.name
    }
    generate_name = "dashboard-"
  }

  type                           = "kubernetes.io/service-account-token"
  wait_for_service_account_token = true
}

resource "kubernetes_cluster_role_binding_v1" "dashboard" {
  metadata {
    name = "admin"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "admin"
    namespace = kubernetes_namespace.dashboard.metadata.0.name
  }
}

resource "helm_release" "dashboard" {
  namespace  = kubernetes_namespace.dashboard.metadata.0.name
  name       = local.dashboard.name
  repository = "https://kubernetes.github.io/dashboard/"
  chart      = "kubernetes-dashboard"
  version    = "7.1.3"

  # set {
  #   name = "app.networkPolicy.enabled"
  #   value = "true"
  # }
  # set {
  #   name = "app.ingress.enabled"
  #   value = "true"
  # }
  # set_list {
  #   name = "app.ingress.hosts"
  #   value = [ "dashboard.localhost", "localhost" ]
  # }
}

output "token" {
  value = kubernetes_secret.dashboard.data
  sensitive = true
}
