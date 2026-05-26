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

variable "deletion_protection" {
  type        = bool
  description = "Whether deletion protection is enabled."
}
