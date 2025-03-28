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

variable "k8s_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.31"
}