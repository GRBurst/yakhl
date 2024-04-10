locals {
  # kube_config = "/etc/rancher/k3s/k3s.yaml" 
  # kube_config = "~/.config/k3d/kubeconfig-pluto.yaml"
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
    kustomization = {
      source  = "kbst/kustomization"
      version = "~> 0.9.5"
    }
    keycloak = {
      source = "mrparkers/keycloak"
      version = ">= 4.0.0"
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

provider "kustomization" {
  kubeconfig_path    = pathexpand(local.kube_config)

  default_tags {
    tags = {
      environment = "dev"
      server      = "pluto"
    }
  }
} 
