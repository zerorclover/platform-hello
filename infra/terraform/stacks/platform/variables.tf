variable "environment" {
  type        = string
  description = "Environment name."
  validation {
    condition     = contains(["dev", "test", "perf", "staging", "production"], var.environment)
    error_message = "environment must be one of dev, test, perf, staging, production."
  }
}

variable "backend_image" {
  type        = string
  description = "Backend image URI."
}

variable "frontend_image" {
  type        = string
  description = "Frontend image URI."
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block supplied by CI/CD."
}

variable "availability_zones" {
  type        = list(string)
  description = "Availability zones supplied by CI/CD."
}

variable "db_name" {
  type        = string
  description = "Database name supplied by CI/CD."
}

variable "db_username" {
  type        = string
  description = "Database username supplied by CI/CD."
}

variable "db_instance_class" {
  type        = string
  description = "RDS instance class supplied by CI/CD."
}

variable "desired_count" {
  type        = number
  description = "Desired ECS task count supplied by CI/CD."
}

variable "deletion_protection" {
  type        = bool
  description = "RDS deletion protection flag supplied by CI/CD."
}

variable "ecs_task_cpu" {
  type        = number
  description = "ECS task CPU units supplied by CI/CD."
}

variable "ecs_task_memory" {
  type        = number
  description = "ECS task memory in MiB supplied by CI/CD."
}

variable "log_retention_days" {
  type        = number
  description = "CloudWatch log retention in days supplied by CI/CD."
}

variable "db_engine_version" {
  type        = string
  description = "RDS PostgreSQL engine version supplied by CI/CD."
}

variable "db_allocated_storage" {
  type        = number
  description = "RDS allocated storage in GiB supplied by CI/CD."
}

variable "db_backup_retention_days" {
  type        = number
  description = "RDS backup retention in days supplied by CI/CD."
}
