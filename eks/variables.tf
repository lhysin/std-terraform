variable "phase" {
  default = "dev"
}

variable "region" {
  default = "ap-northeast-2"
}

variable "vpc_id" {
  description = "exists vpc id"
}


locals {
  service_prefix   = "cjo-${var.phase}"
  service_name     = "study-eks"
  service_kor_desc = "${upper(var.phase)} EKS 스터디"

  cj_enm_tag = {
    phase   = var.phase
    author  = "lhysin"
    owner   = "lhysin"
    team    = "cjenm-arch"
    service = local.service_name
  }
}
