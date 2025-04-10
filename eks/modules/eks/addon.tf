module "mgmt_eks_blueprints_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.20.0"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  enable_argocd = var.enable_argocd

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

  # enable_cert_manager = true
  # cert_manager_route53_hosted_zone_arns = [data.aws_route53_zone.target_hosted_zone.arn]

  enable_external_dns = true
  external_dns_route53_zone_arns = [data.aws_route53_zone.target_hosted_zone.arn]
#   external_dns = {
#     set = [
#       {
#         # alb 생명 주기와 route53 a레코드 생명 주기 싱크
#         name  = "policy"
#         value = "sync"
#       }
#     ]
#   }

  depends_on = [
    module.eks
  ]

  tags = var.tags
}