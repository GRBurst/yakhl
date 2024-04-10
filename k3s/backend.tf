terraform {
  backend "local" {
    path = "../backends/terraform-k3d-backend/terraform.tfstate"
  }
}
