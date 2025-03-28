provider "aws" {
  region  = var.region
  profile = var.profile
}

module "vars" {
  source = "../modules/vars"
  phase  = var.phase
}

locals {
  azs      = [for az in var.azs : "${var.region}${az}"]
  vpc_cidr = var.vpc_cidr
}

module "vpc" {
  source              = "../modules/vpc"
  service_name_prefix = module.vars.service_name_prefix
  service_name_suffix = module.vars.service_name_suffix
  azs                 = local.azs
  vpc_cidr            = local.vpc_cidr
  tags                = module.vars.service_tags
}

module "sg" {
  source              = "../modules/eks-sg"
  service_name_prefix = module.vars.service_name_prefix
  service_name_suffix = module.vars.service_name_suffix
  vpc_id              = module.vpc.vpc_id
  tags                = module.vars.service_tags

  depends_on = [
    module.vpc
  ]
}