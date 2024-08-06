locals {
  kube_config = "~/.kube/config"
  context = "k3d-pluto"
}

terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "~> 2.27.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12.1"
    }
  }
}

provider "kubernetes" {
  config_path    = pathexpand(local.kube_config)
  config_context = local.context
}

provider "helm" {
  kubernetes {
    config_context = local.context
    config_path = pathexpand(local.kube_config)
  }
  # registry {
  #   url = "oci://localhost:5000"
  #   username = "username"
  #   password = "password"
  # }

}
