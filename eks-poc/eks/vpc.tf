data "aws_availability_zones" "available" {}

# VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/24" # 256 IP

  tags = merge(local.cj_enm_tag, {
    Name = "${local.service_prefix}-vpc-${local.service_name}"
  })
}

# Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.cj_enm_tag, {
    Name = "${local.service_prefix}-igw-${local.service_name}"
  })
}

# Elastic IP
resource "aws_eip" "nat" {
  tags = merge(local.cj_enm_tag, {
    Name = "${local.service_prefix}-nat-ip-${local.service_name}"
  })
}

# Nat Gateway
resource "aws_nat_gateway" "gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public-a.id
  tags = merge(local.cj_enm_tag, {
    Name = "${local.service_prefix}-nat-gw-${local.service_name}"
  })
}

# 퍼블릭 서브넷 (EKS 컨트롤 플레인 배치)
resource "aws_subnet" "public-a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.0.0/26" # 64 IP
  availability_zone = data.aws_availability_zones.available.names[0] # a
  map_public_ip_on_launch = true

  tags = merge(local.cj_enm_tag, {
    Name = "${local.service_prefix}-pub-subnet-a-${local.service_name}"
  })
}

resource "aws_subnet" "public-b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.0.64/26" # 64 IP
  availability_zone = data.aws_availability_zones.available.names[1] # b
  map_public_ip_on_launch = true

  tags = merge(local.cj_enm_tag, {
    Name = "${local.service_prefix}-pub-subnet-b-${local.service_name}"
  })
}

# 프라이빗 서브넷 (EKS 노드 그룹 배치)
resource "aws_subnet" "private-a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.0.128/26" # 64 IP
  availability_zone = data.aws_availability_zones.available.names[0] # a
  map_public_ip_on_launch = false

  tags = merge(local.cj_enm_tag, {
    Name = "${local.service_prefix}-pri-subnet-a-${local.service_name}"
  })
}

resource "aws_subnet" "private-b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.0.192/26" # 64 IP
  availability_zone = data.aws_availability_zones.available.names[1] # b
  map_public_ip_on_launch = false

  tags = merge(local.cj_enm_tag, {
    Name = "${local.service_prefix}-pri-subnet-b-${local.service_name}"
  })
}

# 퍼블릭 서브넷 라우트 테이블 (IGW 사용)
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = merge(local.cj_enm_tag, {
    Name = "${local.service_prefix}-pub-route-table-${local.service_name}"
  })
}

# 퍼블릭 서브넷 라우트 테이블 연결
resource "aws_route_table_association" "public-a" {
  subnet_id      = aws_subnet.public-a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public-b" {
  subnet_id      = aws_subnet.public-b.id
  route_table_id = aws_route_table.public.id
}


# 프라이빗 서브넷 라우트 테이블 (NAT Gateway 사용)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.gw.id  # 프라이빗 서브넷의 인터넷 연결용
  }

  tags = merge(local.cj_enm_tag, {
    Name = "${local.service_prefix}-pri-route-table-${local.service_name}"
  })
}

# 프라이빗 서브넷 라우트 테이블 연결
resource "aws_route_table_association" "private-a" {
  subnet_id      = aws_subnet.private-a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private-b" {
  subnet_id      = aws_subnet.private-b.id
  route_table_id = aws_route_table.private.id
}