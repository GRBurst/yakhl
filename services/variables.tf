locals {
  tags = {
    server = "pluto"
  }
  defaults = {
    # host dir = "/media/kubernetes/data"
    # cluster dir = "/kubernetes"
    storage = {
      root = "/kubernetes"
    }
    ingress = {
      prefixes = ["/"]
      strip_prefixes = [ ]
      additional_ingress_annotations = [ ]
      additional_ingress_middlewares = [ ]
    }
  }
}

variable "namespace" {
  type    = string
  default = "pluto"
}
