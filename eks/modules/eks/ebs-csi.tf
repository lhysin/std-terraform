module "ebs_csi_driver_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.20"

  role_name_prefix = "${var.service_name_prefix}-ebs-csi-driver-"

  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }

  tags = var.tags
}

module "eks_blueprints_addons_ebs_csi" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.20.0"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  #enable_aws_efs_csi_driver = true

  eks_addons = {
    aws-ebs-csi-driver = {
      most_recent              = true
      service_account_role_arn = module.ebs_csi_driver_irsa.iam_role_arn
#       configuration_values = jsonencode({
#         sidecars: {
#           snapshotter: {
#             forceEnable: true
#           }
#         }
#       })
    }
  }

  tags = var.tags

  depends_on = [
    module.ebs_csi_driver_irsa
  ]
}