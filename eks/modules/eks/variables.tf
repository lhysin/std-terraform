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

variable "k8s_version" {
  description = "Kubernetes version"
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID where the resources will be deployed"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnet IDs for the VPC"
  type        = list(string)
}

variable "public_subnet_cidr_blocks" {
  description = "List of public subnet cidr blocks for the Public Subnets"
  type        = list(string)
}

variable "private_subnets" {
  description = "List of private subnet IDs for the VPC"
  type        = list(string)
}

variable "alb_ingress_sg_id" {
  description = "The security group ID for the ALB ingress"
  type        = string
}

variable "alb_cjenm_only_ingress_sg_id" {
  description = "The security group ID for the ALB ingress for CJENM Only"
  type        = string
}

variable "eks_suffix_name" {
  description = "Defines the VPC group for EKS multi-cluster environment."
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type = map(string)
}

variable "route53_domain_name" {
  description = "The domain name to be used for Route 53 hosted zone."
  type        = string
  default     = "cjenm-study.com"
}

variable "enable_argocd" {
  type = bool
  default = false
}

variable "enable_ontrust_ingress" {
  type = bool
  default = false
}