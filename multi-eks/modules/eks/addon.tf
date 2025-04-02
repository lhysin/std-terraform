module "mgmt_eks_blueprints_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.20.0"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  enable_argocd = true
  argocd = {
    # https://stackoverflow.com/questions/72903973/how-do-i-add-users-to-argo-cd-using-terraform-resource
    "configs.cm.create"            = true
    "configs.cm.accounts.new-user" = "apiKey, login"
  }

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