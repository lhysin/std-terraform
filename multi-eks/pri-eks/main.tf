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
  vpc_group                 = "pri"
  route53_domain_name       = "cjenm-study.com"
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