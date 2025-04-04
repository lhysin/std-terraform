provider "aws" {
  region  = var.region
  profile = var.profile
}

module "vars" {
  source = "../modules/vars"
  phase  = var.phase
}

module "eks" {
  source                    = "../modules/eks"
  k8s_version               = var.k8s_version
  region                    = var.region
  profile                   = var.profile
  terraform_state_s3_bucket = var.terraform_state_s3_bucket
  terraform_state_s3_key    = var.terraform_state_s3_key
  service_name_prefix       = module.vars.service_name_prefix
  tags                      = module.vars.service_tags
  eks_suffix_name           = "mgmt"
  route53_domain_name       = var.route53_domain_name
}

provider "kubernetes" {
  host                   = module.eks.host
  token                  = module.eks.token
  cluster_ca_certificate = module.eks.ca_certificate
}

provider "helm" {
  kubernetes {
    host                   = module.eks.host
    token                  = module.eks.token
    cluster_ca_certificate = module.eks.ca_certificate
  }
}

data "terraform_remote_state" "shared" {
  backend = "s3"
  config = {
    region  = var.region
    profile = var.profile
    bucket  = var.terraform_state_s3_bucket
    key     = var.terraform_state_s3_key
  }
}

# 이미 등록된 호스팅 존 정보 가져오기
data "aws_route53_zone" "target_hosted_zone" {
  name = "${var.route53_domain_name}." # 대상 도메인 (마침표로 끝나는 FQDN 형식)
}

locals {
  vpc_id          = data.terraform_remote_state.shared.outputs.vpc_id
  public_subnets  = data.terraform_remote_state.shared.outputs.public_subnets
  private_subnets = data.terraform_remote_state.shared.outputs.private_subnets
}