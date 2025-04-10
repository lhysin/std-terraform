provider "aws" {
  region  = var.region
  profile = var.profile
}

module "vars" {
  source = "../../modules/vars"
  phase  = var.phase
}

data "terraform_remote_state" "shared" {
  backend = "s3"
  config = {
    region  = var.region
    profile = var.profile
    bucket  = var.terraform_state_s3_bucket
    key     = var.terraform_state_shared_s3_key
  }
}

data "terraform_remote_state" "mgmt_eks" {
  backend = "s3"
  config = {
    region  = var.region
    profile = var.profile
    bucket  = var.terraform_state_s3_bucket
    key     = var.terraform_state_mgmt_eks_s3_key
  }
}

locals {
  vpc_id                          = data.terraform_remote_state.shared.outputs.vpc_id
  public_subnets                  = data.terraform_remote_state.shared.outputs.public_subnets
  public_subnet_cidr_blocks       = data.terraform_remote_state.shared.outputs.public_subnet_cidr_blocks
  private_subnets                 = data.terraform_remote_state.shared.outputs.private_subnets
  alb_ingress_sg_id               = data.terraform_remote_state.shared.outputs.alb_ingress_sg_id
  alb_cjenm_only_ingress_sg_id    = data.terraform_remote_state.shared.outputs.alb_cjenm_only_ingress_sg_id
  mgmt_eks_node_security_group_id = data.terraform_remote_state.mgmt_eks.outputs.node_security_group_id
}

module "eks" {
  source                       = "../../modules/eks"
  k8s_version                  = var.k8s_version
  region                       = var.region
  profile                      = var.profile
  vpc_id                       = local.vpc_id
  public_subnets               = local.public_subnets
  public_subnet_cidr_blocks    = local.public_subnet_cidr_blocks
  private_subnets              = local.private_subnets
  alb_cjenm_only_ingress_sg_id = local.alb_cjenm_only_ingress_sg_id
  alb_ingress_sg_id            = local.alb_ingress_sg_id
  service_name_prefix          = module.vars.service_name_prefix
  tags                         = module.vars.service_tags
  eks_suffix_name              = "pri"
  route53_domain_name          = var.route53_domain_name
  enable_ontrust_ingress       = true
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