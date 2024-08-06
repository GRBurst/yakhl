terraform {
  backend "local" {
    path = "../backends/terraform-k3d-addons-backend/terraform.tfstate"
  }
}
