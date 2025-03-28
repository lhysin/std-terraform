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
  description = "Aws Availability Zones"
  type        = list(string)
  default     = ["a", "b"]
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}