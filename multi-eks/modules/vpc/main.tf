locals {
  # 서브넷을 나누는 비트 수
  subnet_bits = 8

  # 각 서브넷 타입에 대한 인덱스 설정
  subnet_indices = {
    public  = [1, 2, 3, 4]  # 퍼블릭 서브넷 인덱스
    private = [5, 6, 7, 8]  # 프라이빗 서브넷 인덱스
    intra   = [9, 10, 11, 12]  # 인프라 서브넷 인덱스
  }
}

# 가용 영역을 두 개 설정: us-east-1a, us-east-1b
# azs                 = ["us-east-1a", "us-east-1b"]
# 퍼블릭 서브넷을 두 개 설정: 10.0.3.0/24, 10.0.4.0/24
# Terraform은 서브넷을 가용 영역에 순차적으로 배치합니다.
# public_subnets  = ["10.0.3.0/24", "10.0.4.0/24"]
# us-east-1a에는 10.0.3.0/24 서브넷 배치
# us-east-1b에는 10.0.4.0/24 서브넷 배치

# 가용 영역을 두 개 설정: us-east-1a, us-east-1b
# azs                 = ["us-east-1a", "us-east-1b"]
# 퍼블릭 서브넷을 네 개 설정: 10.0.1.0/24, 10.0.2.0/24, 10.0.3.0/24, 10.0.4.0/24
# Terraform은 서브넷을 가용 영역에 순차적으로 배치합니다.
# public_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24", "10.0.4.0/24"]
# us-east-1a에는 10.0.1.0/24와 10.0.3.0/24 서브넷 배치
# us-east-1b에는 10.0.2.0/24와 10.0.4.0/24 서브넷 배치


module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.service_name_prefix}-vpc-${var.service_name_suffix}"

  cidr            = var.vpc_cidr
  azs = var.azs
  # 각 서브넷 타입에 대한 서브넷 CIDR 동적으로 생성
  public_subnets  = [for idx in local.subnet_indices.public :cidrsubnet(var.vpc_cidr, local.subnet_bits, idx)]
  private_subnets = [for idx in local.subnet_indices.private :cidrsubnet(var.vpc_cidr, local.subnet_bits, idx)]
  intra_subnets   = [for idx in local.subnet_indices.intra :cidrsubnet(var.vpc_cidr, local.subnet_bits, idx)]
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
    Name = "${var.service_name_prefix}-pub-sub-${var.service_name_suffix}"
    #"kubernetes.io/role/elb" = 1
  })

  private_subnet_tags = merge(var.tags, {
    Name = "${var.service_name_prefix}-pri-sub-${var.service_name_suffix}"
    #"kubernetes.io/role/internal-elb" = 1
  })

  intra_subnet_tags = merge(var.tags, {
    Name = "${var.service_name_prefix}-int-sub-${var.service_name_suffix}"
    #"kubernetes.io/role/internal-elb" = 1
  })

  public_route_table_tags = merge(var.tags, {
    Name = "${var.service_name_prefix}-pub-route-table-${var.service_name_suffix}"
  })

  private_route_table_tags = merge(var.tags, {
    Name = "${var.service_name_prefix}-pri-route-table-${var.service_name_suffix}"
  })

  intra_route_table_tags = merge(var.tags, {
    Name = "${var.service_name_prefix}-int-route-table-${var.service_name_suffix}"
  })

  nat_eip_tags = merge(var.tags, {
    Name = "${var.service_name_prefix}-nat-eip-${var.service_name_suffix}"
  })
}