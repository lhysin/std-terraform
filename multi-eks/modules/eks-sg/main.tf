module "cluster_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.3.0"

  name   = "${var.service_name_prefix}-eks-sg-${var.service_name_suffix}"
  vpc_id = var.vpc_id

  # Ingress rules allowing traffic from specific security groups
  ingress_with_source_security_group_id = [
    {
      from_port                = 443
      to_port                  = 443
      protocol                 = "tcp"
      source_security_group_id = module.alb_ingress_sg.security_group_id
      description              = "Allow ALB Ingress security group"
    },
    {
      from_port                = 443
      to_port                  = 443
      protocol                 = "tcp"
      source_security_group_id = module.alb_cjenm_only_ingress_sg.security_group_id
      description              = "Allow ALB CJ ENM Only Ingress security group"
    }
  ]
}

module "alb_ingress_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.3.0"

  name   = "${var.service_name_prefix}-alb-ing-sg-${var.service_name_suffix}"
  vpc_id = var.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
      description = "Allow HTTP access to ALB ingress security group"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
      description = "Allow HTTPS access to ALB ingress security group"
    }
  ]
  tags = var.tags
}

module "alb_cjenm_only_ingress_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.3.0"

  name   = "${var.service_name_prefix}-alb-cjenm-ing-sg-${var.service_name_suffix}"
  vpc_id = var.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = "210.122.105.0/24"
      description = "Allow HTTP access for a specific IP range"
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = "210.122.106.0/24"
      description = "Allow HTTP access for a specific IP range"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = "210.122.105.0/24"
      description = "Allow HTTPS access for a specific IP range"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = "210.122.106.0/24"
      description = "Allow HTTPS access for a specific IP range"
    }
  ]

  tags = var.tags
}
