locals {
  name        = "platform-hello-${var.environment}"
  db_name     = "platform"
  db_username = "platform"

  environment_config = {
    dev = {
      vpc_cidr            = "10.10.0.0/16"
      availability_zones  = ["us-west-2a", "us-west-2b"]
      db_instance_class   = "db.t4g.micro"
      desired_count       = 1
      deletion_protection = false
    }
    test = {
      vpc_cidr            = "10.20.0.0/16"
      availability_zones  = ["us-west-2a", "us-west-2b"]
      db_instance_class   = "db.t4g.micro"
      desired_count       = 1
      deletion_protection = false
    }
    perf = {
      vpc_cidr            = "10.30.0.0/16"
      availability_zones  = ["us-west-2a", "us-west-2b"]
      db_instance_class   = "db.t4g.small"
      desired_count       = 2
      deletion_protection = false
    }
    staging = {
      vpc_cidr            = "10.40.0.0/16"
      availability_zones  = ["us-west-2a", "us-west-2b"]
      db_instance_class   = "db.t4g.small"
      desired_count       = 2
      deletion_protection = true
    }
    production = {
      vpc_cidr            = "10.50.0.0/16"
      availability_zones  = ["us-west-2a", "us-west-2b"]
      db_instance_class   = "db.t4g.medium"
      desired_count       = 3
      deletion_protection = true
    }
  }

  selected_environment = local.environment_config[var.environment]
}

module "network" {
  source             = "../../modules/network"
  name               = local.name
  cidr_block         = local.selected_environment.vpc_cidr
  availability_zones = local.selected_environment.availability_zones
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
  desired_count      = local.selected_environment.desired_count
  database_url_secret_arn = module.data.database_url_secret_arn
}

module "data" {
  source              = "../../modules/data"
  name                = local.name
  vpc_id              = module.network.vpc_id
  private_subnet_ids   = module.network.private_subnet_ids
  allowed_cidr_blocks = module.network.private_subnet_cidr_blocks
  db_name             = local.db_name
  db_username         = local.db_username
  db_instance_class   = local.selected_environment.db_instance_class
  deletion_protection = local.selected_environment.deletion_protection
}
