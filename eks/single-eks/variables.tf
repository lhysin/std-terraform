variable "profile" {
  description = "AWS profile"
  type        = string
  default     = "cjenm-itarch"
}

variable "phase" {
  description = "Phase"
  type        = string
  default     = "std"
}

variable "region" {
  description = "Aws Region"
  type        = string
  default     = "ap-northeast-2"
}

variable "azs" {
  description = "A list of short availability zone identifiers (e.g., 'a', 'b', etc.) corresponding to the actual AWS availability zones in the region."
  type = list(string)
  default = ["a", "b"]
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "k8s_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.31"
}

variable "route53_domain_name" {
  description = "The domain name to be used for Route 53 hosted zone."
  type        = string
  default     = "cjenm-study.com"
}