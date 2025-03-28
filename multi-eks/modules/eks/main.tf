module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.34.0"

  cluster_name    = "${var.service_name_prefix}-eks"
  cluster_version = var.k8s_version

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnets
  control_plane_subnet_ids = var.intra_subnets

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
      from_port   = 443
      to_port     = 443
      cidr_blocks = ["0.0.0.0/0"]
      type        = "ingress"
    }
  }

  # 관리 클러스터는 노드 그룹을 적게 둠
  eks_managed_node_groups = {
    "${var.service_name_prefix}-eks-ng" = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      #ami_type      = "AL2023_x86_64_STANDARD"
      ami_type      = "AL2_ARM_64"
      instance_types = ["t4g.medium"]
      # ON_DEMAND(default), SPOT
      capacity_type = "SPOT"
      min_size      = 2
      max_size      = 4
      desired_size  = 2
    }
  }

  tags = var.tags
}

data "aws_eks_cluster_auth" "cluster_auth" {
  name = module.eks.cluster_name
}

module "mgmt_eks_blueprints_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.20.0"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  enable_argocd = true

  enable_aws_cloudwatch_metrics = true
  enable_metrics_server         = true

  # https://www.gomgomshrimp.com/posts/k8s/karpenter-autoscaling
  #enable_cluster_autoscaler = true
  enable_karpenter = true

  # Turn off mutation webhook for services to avoid ordering issue
  enable_aws_load_balancer_controller = true
  aws_load_balancer_controller = {
    set = [
      {
        name  = "enableServiceMutatorWebhook"
        value = "false"
      }
    ]
  }

  #   enable_cert_manager = true
  #   cert_manager_route53_hosted_zone_arns = [data.aws_route53_zone.target_hosted_zone.arn]
  #
  #   enable_external_dns = true
  #   external_dns_route53_zone_arns = [data.aws_route53_zone.target_hosted_zone.arn]

  #   helm_releases = {
  #     kubecost = {
  #       name             = "kubecost"
  #       namespace        = "kubecost"
  #       create_namespace = true
  #       repository       = "https://kubecost.github.io/cost-analyzer"
  #       chart            = "kubecost/cost-analyzer"
  #       version          = "2.6.5"
  #     }
  #   }

  depends_on = [
    module.eks
  ]

  tags = var.tags
}


# kubectl get secret -n argocd argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode && echo
# 최초 로그인 이후 xharhdiddl!@# (톰고양이123)으로 변경


# data "aws_lb" "eks_alb_argo_cd" {
#   tags = {
#     "ingress.k8s.aws/stack" = "${local.argo_cd_ingress_namespace}/${local.argo_cd_ingress_name}"
#   }
#   depends_on = [kubernetes_ingress_v1.argocd_ingress]
# }
#
#
# resource "aws_route53_record" "argo_cd_cname" {
#   zone_id = data.aws_route53_zone.target_hosted_zone.zone_id
#   name    = "eks-test-argocd.${var.route53_domain_name}"
#   type    = "CNAME"
#   ttl     = 60
#   records = [data.aws_lb.eks_alb_argo_cd.dns_name]
#   depends_on = [
#     data.aws_lb.eks_alb_argo_cd
#   ]
# }