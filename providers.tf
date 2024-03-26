terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.27.0"
    }
    keycloak = {
      source = "mrparkers/keycloak"
      version = ">= 4.0.0"
    }
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "minikube"
}

provider "helm" {
  kubernetes {
    config_context_cluster = "minikube"
  }
}
