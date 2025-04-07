data "terraform_remote_state" "shared" {
  backend = "s3"
  config = {
    region  = var.region
    profile = var.profile
    bucket  = var.terraform_state_s3_bucket
    key     = var.terraform_state_s3_key
  }
}

# 이미 등록된 호스팅 존 정보 가져오기
data "aws_route53_zone" "target_hosted_zone" {
  name = "${var.route53_domain_name}." # 대상 도메인 (마침표로 끝나는 FQDN 형식)
}


locals {
  vpc_id          = data.terraform_remote_state.shared.outputs.vpc_id
  public_subnets  = data.terraform_remote_state.shared.outputs.public_subnets
  private_subnets = data.terraform_remote_state.shared.outputs.private_subnets
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.34.0"

  cluster_name    = "${var.service_name_prefix}-${var.eks_suffix_name}-eks"
  cluster_version = var.k8s_version

  vpc_id     = local.vpc_id
  subnet_ids = local.private_subnets
  control_plane_subnet_ids = local.public_subnets

  # https://stackoverflow.com/questions/79270303/eks-cluster-with-managed-nodegroups-in-private-subnets-fail-with-instances-fail
  bootstrap_self_managed_addons = true

  # 외부에서 k8s API 접근 여부
  cluster_endpoint_public_access = true
  # vpc k8s API 접근 여부
  cluster_endpoint_private_access = true
  # 클러스터 생성 IAM에 관리자 권한 부여 여부
  enable_cluster_creator_admin_permissions = true
  # 클러스터 노드용 보안그룹(security group) 자동 생성 여부
  create_node_security_group = true

  node_security_group_additional_rules = {
    ingress_argo = {
      description = "Allow ArgoCD access"
      protocol    = "tcp"
      from_port   = 8080
      to_port     = 8080
      cidr_blocks = ["0.0.0.0/0"]
      type        = "ingress"
    }
  }

  # 관리 클러스터는 노드 그룹을 적게 둠
  eks_managed_node_groups = {
    "${var.service_name_prefix}-eks-ng" = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
#       ami_type      = "AL2023_x86_64_STANDARD"
#       instance_types = ["t3.medium"]
      ami_type      = "AL2_ARM_64"
      instance_types = ["t4g.medium"]
      # ON_DEMAND(default), SPOT
      capacity_type = "SPOT"
      min_size      = 1
      max_size      = 4
      desired_size  = 2
    }
  }

  tags = var.tags
}

data "aws_eks_cluster_auth" "cluster_auth" {
  name = module.eks.cluster_name
}