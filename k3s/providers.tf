locals {
  kube_config = "/etc/rancher/k3s/k3s.yaml" # "~/.kube/config"
}

terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "~> 2.27.0"
    }
    keycloak = {
      source = "mrparkers/keycloak"
      version = ">= 4.0.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12.1"
    }
  }
}

provider "kubernetes" {
  config_path    = pathexpand(local.kube_config)
  config_context = "default"
}

provider "helm" {
  kubernetes {
    config_context = "default"
    config_path = pathexpand(local.kube_config)
  }
}
