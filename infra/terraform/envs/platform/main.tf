provider "aws" {
  region = var.aws_region
}

module "platform" {
  source                   = "../../stacks/platform"
  environment              = var.environment
  backend_image            = var.backend_image
  frontend_image           = var.frontend_image
  vpc_cidr                 = var.vpc_cidr
  availability_zones       = var.availability_zones
  db_name                  = var.db_name
  db_username              = var.db_username
  db_instance_class        = var.db_instance_class
  desired_count            = var.desired_count
  deletion_protection      = var.deletion_protection
  ecs_task_cpu             = var.ecs_task_cpu
  ecs_task_memory          = var.ecs_task_memory
  log_retention_days       = var.log_retention_days
  db_engine_version        = var.db_engine_version
  db_allocated_storage     = var.db_allocated_storage
  db_backup_retention_days = var.db_backup_retention_days
}
