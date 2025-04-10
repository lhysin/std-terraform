variable "service_name_prefix" {
  description = "Service Name Prefix"
  type        = string
}

variable "service_name_suffix" {
  description = "Service Name Suffix"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the Default VPC"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type = map(string)
}