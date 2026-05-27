variable "environment" {
  type        = string
  description = "Target environment: dev, test, perf, staging, or production."
}

variable "backend_image" {
  type        = string
  description = "Backend container image URI."
}

variable "frontend_image" {
  type        = string
  description = "Frontend container image URI."
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
