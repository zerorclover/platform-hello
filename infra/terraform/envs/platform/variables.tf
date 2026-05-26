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
