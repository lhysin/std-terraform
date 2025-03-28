data "aws_availability_zones" "available" {}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.service_name_prefix}-vpc-${var.service_name_suffix}"

  cidr = var.vpc_cidr

  azs             = var.azs
  private_subnets = [for k, v in var.azs : cidrsubnet(var.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in var.azs : cidrsubnet(var.vpc_cidr, 8, k + 48)]
  intra_subnets   = [for k, v in var.azs : cidrsubnet(var.vpc_cidr, 8, k + 52)]

  enable_dns_support = true
  enable_dns_hostnames = true

  # Single NAT Gateway
  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  vpc_tags = merge(var.tags, {
    Name = "${var.service_name_prefix}-vpc-${var.service_name_suffix}"
  })

  igw_tags = merge(var.tags, {
    Name = "${var.service_name_prefix}-ig-gw-${var.service_name_suffix}"
  })

  nat_gateway_tags = merge(var.tags, {
    Name = "${var.service_name_prefix}-nat-gw-${var.service_name_suffix}"
  })

  public_subnet_tags = merge(var.tags, {
    Name = "${var.service_name_prefix}-pub-subnet-${var.service_name_suffix}"
    #"kubernetes.io/role/elb" = 1
  })

  private_subnet_tags = merge(var.tags, {
    Name = "${var.service_name_prefix}-pri-subnet-${var.service_name_suffix}"
    #"kubernetes.io/role/internal-elb" = 1
  })

  intra_subnet_tags = merge(var.tags, {
    Name = "${var.service_name_prefix}-inf-subnet-${var.service_name_suffix}"
    #"kubernetes.io/role/internal-elb" = 1
  })

  public_route_table_tags = merge(var.tags, {
    Name = "${var.service_name_prefix}-pub-route-table-${var.service_name_suffix}"
  })

  private_route_table_tags = merge(var.tags, {
    Name = "${var.service_name_prefix}-pri-route-table-${var.service_name_suffix}"
  })

  intra_route_table_tags = merge(var.tags, {
    Name = "${var.service_name_prefix}-inf-route-table-${var.service_name_suffix}"
  })

  nat_eip_tags = merge(var.tags, {
    Name = "${var.service_name_prefix}-nat-eip-${var.service_name_suffix}"
  })
}