variable "service_name_prefix" {
  description = "Service Name Prefix"
  type        = string
}

variable "service_name_suffix" {
  description = "Service Name Suffix"
  type        = string
}

variable "azs" {
  description = "List of availability zones"
}

variable "vpc_cidr" {
  description = "VPC CIDR"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type = map(string)
}