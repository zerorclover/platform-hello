variable "name_prefix" {
  type        = string
  description = "Name prefix for container platform resources."
}

variable "short_name_prefix" {
  type        = string
  description = "Short name prefix for resources with strict AWS name length limits."
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

variable "database_url_secret_arn" {
  type        = string
  description = "Secrets Manager ARN containing the PostgreSQL connection URL."
  sensitive   = true
}

variable "desired_count" {
  type        = number
  description = "Desired ECS task count for each service."
}

variable "ecs_task_cpu" {
  type        = number
  description = "ECS task CPU units."
}

variable "ecs_task_memory" {
  type        = number
  description = "ECS task memory in MiB."
}

variable "log_retention_days" {
  type        = number
  description = "CloudWatch log retention in days."
}

variable "tags" {
  type        = map(string)
  description = "Common tags applied to container platform resources."
}
