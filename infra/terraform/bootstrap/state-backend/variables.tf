variable "aws_region" {
  type        = string
  description = "AWS region for the Terraform state backend resources."
}

variable "state_bucket_name" {
  type        = string
  description = "Globally unique S3 bucket name for Terraform state."
}

variable "lock_table_name" {
  type        = string
  description = "DynamoDB table name for Terraform state locking."
}

variable "tags" {
  type        = map(string)
  description = "Additional tags for Terraform state backend resources."
  default     = {}
}
