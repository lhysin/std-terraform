variable "phase" {
  default = "dev"
}

variable "region" {
  default = "ap-northeast-2"
}

variable "eks_admin_ids" {
  description = "IAM 사용자 ID 리스트"
  type        = list(string)  # 문자열 리스트 형태로 정의
}

# variable "vpc_id" {
#   description = "exists vpc id"
# }

variable "k8s_version" {
  description = "kubernetes version"
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
