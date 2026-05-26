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
