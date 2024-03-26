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
  config_path    = "/etc/rancher/k3s/k3s.yaml"
  config_context = "default"
}

provider "helm" {
  kubernetes {
    config_context = "default"
  }
}
