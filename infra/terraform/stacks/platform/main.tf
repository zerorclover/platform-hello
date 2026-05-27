locals {
  project           = "platform-hello"
  name_prefix       = "${local.project}-${var.environment}"
  short_name_prefix = "ph-${var.environment}"
  common_tags = {
    Application = local.project
    Environment = var.environment
    ManagedBy   = "terraform"
    Project     = local.project
  }
}

module "network" {
  source             = "../../modules/network"
  name_prefix        = local.name_prefix
  cidr_block         = var.vpc_cidr
  availability_zones = var.availability_zones
  tags               = local.common_tags
}

module "container_platform" {
  source                  = "../../modules/container-platform"
  name_prefix             = local.name_prefix
  short_name_prefix       = local.short_name_prefix
  environment             = var.environment
  vpc_id                  = module.network.vpc_id
  public_subnet_ids       = module.network.public_subnet_ids
  private_subnet_ids      = module.network.private_subnet_ids
  backend_image           = var.backend_image
  frontend_image          = var.frontend_image
  desired_count           = var.desired_count
  ecs_task_cpu            = var.ecs_task_cpu
  ecs_task_memory         = var.ecs_task_memory
  log_retention_days      = var.log_retention_days
  database_url_secret_arn = module.data.database_url_secret_arn
  tags                    = local.common_tags
}

module "data" {
  source                   = "../../modules/data"
  name_prefix              = local.name_prefix
  vpc_id                   = module.network.vpc_id
  private_subnet_ids       = module.network.private_subnet_ids
  allowed_cidr_blocks      = module.network.private_subnet_cidr_blocks
  db_name                  = var.db_name
  db_username              = var.db_username
  db_instance_class        = var.db_instance_class
  db_engine_version        = var.db_engine_version
  db_allocated_storage     = var.db_allocated_storage
  db_backup_retention_days = var.db_backup_retention_days
  deletion_protection      = var.deletion_protection
  tags                     = local.common_tags
}
