module "mgmt_cluster_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.3.0"

  name   = "${local.service_prefix}-mgmt-cluster-sg-${local.service_surfix}"
  vpc_id = module.vpc.vpc_id

  # ArgoCD, Prometheus, ELK 접근 허용
  ingress_with_cidr_blocks = [
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
      description = "Allow HTTPS access to ArgoCD and Grafana"
    }
  ]

  # 액티브 & 스탠바이 클러스터의 API 서버 접근 허용
  ingress_with_source_security_group_id = [
    {
      from_port                = 6443
      to_port                  = 6443
      protocol                 = "tcp"
      source_security_group_id = module.active_cluster_sg.security_group_id
      description              = "Allow access to Active Cluster API"
    },
    {
      from_port                = 6443
      to_port                  = 6443
      protocol                 = "tcp"
      source_security_group_id = module.standby_cluster_sg.security_group_id
      description              = "Allow access to Standby Cluster API"
    }
  ]
}

module "active_cluster_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.3.0"

  name   = "${local.service_prefix}-active-cluster-sg-${local.service_surfix}"
  vpc_id = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
      description = "Allow HTTP access to Active Cluster"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
      description = "Allow HTTPS access to Active Cluster"
    }
  ]

  # 매니지먼트 클러스터에서 API 요청 가능하도록 허용
  ingress_with_source_security_group_id = [
    {
      from_port                = 6443
      to_port                  = 6443
      protocol                 = "tcp"
      source_security_group_id = module.mgmt_cluster_sg.security_group_id
      description              = "Allow Management Cluster to access API"
    }
  ]
}

module "standby_cluster_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.3.0"

  name   = "${local.service_prefix}-stanby-cluster-sg-${local.service_surfix}"
  vpc_id = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
      description = "Allow HTTP access to Standby Cluster"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
      description = "Allow HTTPS access to Standby Cluster"
    }
  ]

  # 매니지먼트 클러스터에서 API 요청 가능하도록 허용
  ingress_with_source_security_group_id = [
    {
      from_port                = 6443
      to_port                  = 6443
      protocol                 = "tcp"
      source_security_group_id = module.mgmt_cluster_sg.security_group_id
      description              = "Allow Management Cluster to access API"
    }
  ]
}

module "alb_ingress_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.3.0"

  name   = "${local.service_prefix}-alb_ing-sg-${local.service_surfix}"
  vpc_id = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
      description = "Allow HTTP access to ALB Ingress"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
      description = "Allow HTTPS access to ALB Ingress"
    }
  ]
}