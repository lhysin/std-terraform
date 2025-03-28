provider "aws" {
  region  = var.region
  profile = var.profile
}

module "vars" {
  source = "../modules/vars"
  phase = var.phase
}

data "terraform_remote_state" "shared" {
  backend = "s3"
  config = {
    bucket = "cjo-std-s3-terraform-state"
    key    = "multi-eks/shared/std/terraform.tfstate"
    region = var.region
    profile = var.profile
  }
}

module "ab_eks" {
  source              = "../modules/eks"
  k8s_version         = var.k8s_version
  service_name_prefix = "${module.vars.service_name_prefix}-ab"
  vpc_id              =  data.terraform_remote_state.shared.outputs.ab_vpc_id
  public_subnets      =  data.terraform_remote_state.shared.outputs.ab_public_subnets
  private_subnets     = data.terraform_remote_state.shared.outputs.ab_private_subnets
  intra_subnets       = data.terraform_remote_state.shared.outputs.ab_infra_subnets
  tags                = module.vars.service_tags
}

provider "kubernetes" {
  host                   = module.ab_eks.host
  token                  = module.ab_eks.token
  cluster_ca_certificate = module.ab_eks.ca_certificate
}

provider "helm" {
  kubernetes {
    host                   = module.ab_eks.host
    token                  = module.ab_eks.token
    cluster_ca_certificate = module.ab_eks.ca_certificate
  }
}