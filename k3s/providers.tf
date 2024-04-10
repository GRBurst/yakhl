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
    k3d = {
        source  = "nikhilsbhat/k3d"
        version = "0.0.2"
    }
  }
}

provider "k3d" {
    kubernetes_version = "1.24.4-k3s1" #"v1.29.3+k3s1"
    k3d_api_version    = "k3d.io/v1alpha4" # "k3d.io/v1alpha5"
    registry           = "rancher/k3s"
    kind               = "Simple"
    runtime            = "docker"
}
