variable "service_name_prefix" {
  description = "Service Name Prefix"
  type        = string
}

variable "profile" {
  description = "AWS profile"
  type        = string
}

variable "region" {
  description = "AWS Region"
  type        = string
}

variable "vpc_group" {
  description = "Defines the VPC group for EKS multi-cluster environment. 'pri' is for the first VPC (private), and 'sec' is for the secondary VPC (public)."
  type        = string
}

variable "terraform_state_s3_bucket" {
  description = "The name of the S3 bucket where Terraform state files are stored."
  type        = string
}

variable "terraform_state_s3_key" {
  description = "The path (key) to the specific Terraform state file within the S3 bucket."
  type        = string
}

variable "k8s_version" {
  description = "Kubernetes version"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type = map(string)
}

variable "route53_domain_name" {
  description = ""
  type = string
}