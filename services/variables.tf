locals {
  tags = {
    server = "pluto"
  }
  defaults = {
    root = "/kubernetes"
  }
}

variable "namespace" {
  type    = string
  default = "pluto"
}
