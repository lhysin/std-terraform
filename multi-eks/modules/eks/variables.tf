variable "service_name_prefix" {
  description = "Service Name Prefix"
  type        = string
}

variable "k8s_version" {
  description = "Kubernetes version."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the Default VPC"
  type        = string
}

variable "private_subnets" {
  description = "List of IDs of private subnets"
  type = list(string)
}

variable "public_subnets" {
  description = "List of IDs of public subnets"
  type = list(string)
}

variable "intra_subnets" {
  description = "List of IDs of intra subnets"
  type = list(string)
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type = map(string)
}