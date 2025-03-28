locals {
  service_name_prefix = "cjos-${var.phase}"
  service_name_suffix = "study-multi-eks"
  service_kor_desc    = "${upper(var.phase)} EKS 스터디"

  service_tags = {
    phase   = var.phase
    author  = "lhysin"
    owner   = "lhysin"
    team    = "cjenm-arch"
    service = "study-multi-eks"
  }
}