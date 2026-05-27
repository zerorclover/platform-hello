variable "name_prefix" {
  type        = string
  description = "Name prefix for network resources."
}

variable "cidr_block" {
  type        = string
  description = "VPC CIDR block."
}

variable "availability_zones" {
  type        = list(string)
  description = "Availability zones to use."
}

variable "tags" {
  type        = map(string)
  description = "Common tags applied to network resources."
}
