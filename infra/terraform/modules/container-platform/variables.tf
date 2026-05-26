variable "name" {
  type        = string
  description = "Name prefix for container platform resources."
}

variable "vpc_id" {
  type        = string
  description = "VPC ID."
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "Public subnets for the ALB."
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnets for ECS tasks."
}

variable "environment" {
  type        = string
  description = "Deployment environment name."
}

variable "backend_image" {
  type        = string
  description = "Backend container image URI."
}

variable "frontend_image" {
  type        = string
  description = "Frontend container image URI."
}

variable "database_url" {
  type        = string
  description = "PostgreSQL connection URL."
  sensitive   = true
}

variable "desired_count" {
  type        = number
  description = "Desired ECS task count for each service."
}
