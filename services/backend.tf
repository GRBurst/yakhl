terraform {
  backend "local" {
    path = "../backends/terraform-services-backend/terraform.tfstate"
  }
}
