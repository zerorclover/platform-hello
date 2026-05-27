provider "aws" {
  region = var.aws_region
}

module "platform" {
  source              = "../../stacks/platform"
  environment         = var.environment
  backend_image       = var.backend_image
  frontend_image      = var.frontend_image
  vpc_cidr            = var.vpc_cidr
  availability_zones  = var.availability_zones
  db_name             = var.db_name
  db_username         = var.db_username
  db_instance_class   = var.db_instance_class
  desired_count       = var.desired_count
  deletion_protection = var.deletion_protection
}
