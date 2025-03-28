data "aws_availability_zones" "available" {}

locals {
  vpc_cidr = "10.0.0.0/16"
  azs = slice(data.aws_availability_zones.available.names, 0, 3)
}

# VPC
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${local.service_prefix}-vpc-${local.service_surfix}"

  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)]
  intra_subnets   = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 52)]

  enable_dns_support = true
  enable_dns_hostnames = true

  # Single NAT Gateway
  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  vpc_tags = merge(local.cj_enm_tag, {
    Name = "${local.service_prefix}-vpc-${local.service_surfix}"
  })

  igw_tags = merge(local.cj_enm_tag, {
    Name = "${local.service_prefix}-ig-gw-${local.service_surfix}"
  })

  nat_gateway_tags = merge(local.cj_enm_tag, {
    Name = "${local.service_prefix}-nat-gw-${local.service_surfix}"
  })

  public_subnet_tags = merge(local.cj_enm_tag, {
    Name = "${local.service_prefix}-pub-subnet-${local.service_surfix}"
    #"kubernetes.io/role/elb" = 1
  })

  private_subnet_tags = merge(local.cj_enm_tag, {
    Name = "${local.service_prefix}-pri-subnet-${local.service_surfix}"
    #"kubernetes.io/role/internal-elb" = 1
  })

  intra_subnet_tags = merge(local.cj_enm_tag, {
    Name = "${local.service_prefix}-inf-subnet-${local.service_surfix}"
    #"kubernetes.io/role/internal-elb" = 1
  })

  public_route_table_tags = merge(local.cj_enm_tag, {
    Name = "${local.service_prefix}-pub-route-table-${local.service_surfix}"
  })

  private_route_table_tags = merge(local.cj_enm_tag, {
    Name = "${local.service_prefix}-pri-route-table-${local.service_surfix}"
  })

  intra_route_table_tags = merge(local.cj_enm_tag, {
    Name = "${local.service_prefix}-inf-route-table-${local.service_surfix}"
  })

  nat_eip_tags = merge(local.cj_enm_tag, {
    Name = "${local.service_prefix}-nat-eip-${local.service_surfix}"
  })
}