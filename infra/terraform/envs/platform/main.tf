provider "aws" {
  region = "us-west-2"
}

module "platform" {
  source         = "../../stacks/platform"
  environment    = var.environment
  backend_image  = var.backend_image
  frontend_image = var.frontend_image
}
