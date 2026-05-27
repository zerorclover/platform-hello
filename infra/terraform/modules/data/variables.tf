variable "name" {
  type        = string
  description = "Name prefix for data resources."
}

variable "vpc_id" {
  type        = string
  description = "VPC ID."
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs for RDS."
}

variable "allowed_cidr_blocks" {
  type        = list(string)
  description = "CIDR blocks allowed to connect to the database."
}

variable "db_name" {
  type        = string
  description = "Database name."
}

variable "db_username" {
  type        = string
  description = "Database username."
}

variable "db_instance_class" {
  type        = string
  description = "RDS instance class."
}

variable "db_engine_version" {
  type        = string
  description = "RDS PostgreSQL engine version."
}

variable "db_allocated_storage" {
  type        = number
  description = "RDS allocated storage in GiB."
}

variable "db_backup_retention_days" {
  type        = number
  description = "RDS backup retention in days."
}

variable "deletion_protection" {
  type        = bool
  description = "Whether deletion protection is enabled."
}
