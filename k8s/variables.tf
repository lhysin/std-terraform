variable "phase" {
  default = "dev"
}

variable "region" {
  default = "ap-northeast-2"
}

variable "route53_domain_name" {
    default = "cjenm-study.com"
  description = "라우트 53에 등록된 도메인 네임"
}