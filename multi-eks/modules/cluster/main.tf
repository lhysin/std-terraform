module "vars" {
  source = "../../modules/vars"
  phase = var.phase
}

module "vpc" {
  source              = "../../modules/vpc"
  service_name_prefix = module.vars.service_name_prefix
  service_name_suffix = module.vars.service_name_suffix
  azs                 = [for az in var.azs : "${var.region}${az}"]
  vpc_cidr            = var.vpc_cidr
  tags                = module.vars.service_tags
}

module "sg" {
  source              = "../eks-sg"
  service_name_prefix = module.vars.service_name_prefix
  service_name_suffix = module.vars.service_name_suffix
  vpc_id              = module.vpc.vpc_id
  tags                = module.vars.service_tags
  depends_on = [
    module.vpc
  ]
}

module "eks" {
  source              = "../../modules/eks"
  k8s_version         = var.k8s_version
  service_name_prefix = "${module.vars.service_name_prefix}-${join("", var.azs)}"
  vpc_id              = module.vpc.vpc_id
  public_subnets      = module.vpc.public_subnets
  private_subnets     = module.vpc.private_subnets
  intra_subnets       = module.vpc.intra_subnets
  tags                = module.vars.service_tags
  depends_on = [
    module.vpc,
    module.sg
  ]
}





