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

variable "terraform_state_s3_bucket" {
  description = "The name of the S3 bucket where Terraform state files are stored."
  type        = string
  default     = "cjo-std-s3-terraform-state"
}

variable "terraform_state_s3_key" {
  description = "The path (key) to the specific Terraform state file within the S3 bucket."
  type        = string
  default     = "multi-eks/shared/std/terraform.tfstate"
}