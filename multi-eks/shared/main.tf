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

module "eks_sg" {
  source              = "../modules/eks-sg"
  service_name_prefix = module.vars.service_name_prefix
  service_name_suffix = module.vars.service_name_suffix
  vpc_id              = module.vpc.vpc_id
  tags                = module.vars.service_tags

  depends_on = [
    module.vpc
  ]
}

module "rancher" {
  source              = "../modules/rancher"
  service_name_prefix = module.vars.service_name_prefix
  service_name_suffix = module.vars.service_name_suffix
  vpc_id = module.vpc.vpc_id
  public_subnets = module.vpc.public_subnets
  alb_cjenm_only_ingress_sg_id = module.eks_sg.alb_cjenm_only_ingress_sg_id
  route53_domain_name = var.route53_domain_name

  tags                = module.vars.service_tags

  depends_on = [
    module.vpc,
    module.eks_sg
  ]
  ssh_sg_id = module.eks_sg.ssh_sg_id
  alb_ingress_sg_id = module.eks_sg.alb_ingress_sg_id
}

