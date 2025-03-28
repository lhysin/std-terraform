variable "region" {
  description = "AWS Region"
  type        = string
}

variable "phase" {
  description = "Phase"
  type        = string
}

variable "azs" {
  description = "A list of Availability zones in the region"
  type = list(string)
}

variable "vpc_cidr" {
  description = "VPC CIDR"
}

variable "k8s_version" {
  description = "Kubernetes version"
  type        = string
}