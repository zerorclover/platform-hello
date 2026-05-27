locals {
  name = "platform-hello-${var.environment}"
}

module "network" {
  source             = "../../modules/network"
  name               = local.name
  cidr_block         = var.vpc_cidr
  availability_zones = var.availability_zones
}

module "container_platform" {
  source             = "../../modules/container-platform"
  name               = local.name
  environment        = var.environment
  vpc_id             = module.network.vpc_id
  public_subnet_ids  = module.network.public_subnet_ids
  private_subnet_ids = module.network.private_subnet_ids
  backend_image      = var.backend_image
  frontend_image     = var.frontend_image
  desired_count      = var.desired_count
  database_url_secret_arn = module.data.database_url_secret_arn
}

module "data" {
  source              = "../../modules/data"
  name                = local.name
  vpc_id              = module.network.vpc_id
  private_subnet_ids   = module.network.private_subnet_ids
  allowed_cidr_blocks = module.network.private_subnet_cidr_blocks
  db_name             = var.db_name
  db_username         = var.db_username
  db_instance_class   = var.db_instance_class
  deletion_protection = var.deletion_protection
}
