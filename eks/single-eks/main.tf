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

module "eks" {
  source                       = "../modules/eks"
  k8s_version                  = var.k8s_version
  region                       = var.region
  profile                      = var.profile
  vpc_id                       = module.vpc.vpc_id
  public_subnets               = module.vpc.public_subnets
  public_subnet_cidr_blocks    = module.vpc.public_subnet_cidr_blocks
  private_subnets              = module.vpc.private_subnets
  alb_cjenm_only_ingress_sg_id = module.eks_sg.alb_cjenm_only_ingress_sg_id
  alb_ingress_sg_id            = module.eks_sg.alb_ingress_sg_id
  service_name_prefix          = module.vars.service_name_prefix
  tags                         = module.vars.service_tags
  eks_suffix_name              = "single"
  route53_domain_name          = var.route53_domain_name
  enable_argocd                = false
  enable_ontrust_ingress       = false

  depends_on = [
    module.vpc,
    module.eks_sg
  ]
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