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
}

variable "public_subnets" {
  description = "List of IDs of public subnets"
}

variable "alb_cjenm_only_ingress_sg_id" {
  description = "The ID of the security group for the ALB ingress, restricted to CJENM-specific traffic."
}

variable "route53_domain_name" {
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type = map(string)
}

variable "ssh_sg_id" {
  description = "The ID of the security group for SSH access."
}

variable "alb_ingress_sg_id" {
  description = "The ID of the security group associated with the Application Load Balancer (ALB) ingress."
}