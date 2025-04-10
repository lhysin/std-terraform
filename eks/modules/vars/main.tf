locals {
  service_name_prefix = "cjo-${var.phase}"
  service_name_suffix = "eks"
  service_kor_desc    = "${upper(var.phase)} EKS 스터디"

  service_tags = {
    phase   = var.phase
    author  = "lhysin"
    owner   = "lhysin"
    team    = "cjenm-arch"
    service = "study-multi-eks"
  }
}