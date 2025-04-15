variable "project" {
  description = "Project Name"
  type        = string
  default     = "cjenm-ads"
}

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

variable "vpc_id" {
  description = "VPC ID"
  type        = string
  default     = "vpc-02c098b71abf0b0de"
}

variable "public_subnets" {
  description = "Public Subnet 목록"
  type = list(string)
  default = [
    "subnet-032fa12ccf2b1eb73",
    "subnet-0f5ffceef9f887796",
  ]
}

variable "private_subnets" {
  description = "Private Subnet 목록"
  type = list(string)
  default = [
    "subnet-05dc1bd2f03d71930",
    "subnet-0aab7fcde28fc88c1",
  ]
}

variable "domain" {
  description = "도메인"
  type        = string
  default     = "cjenm-study.com"
}