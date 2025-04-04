module "ebs_csi_driver_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.20"

  role_name_prefix = "${module.vars.service_name_prefix}-ebs-csi-driver-"

  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }

  tags = module.vars.service_tags
}

module "eks_blueprint_aws_addons_aws_ebs_csi_driver" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.20.0"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  eks_addons = {
    aws-ebs-csi-driver = {
      most_recent              = true
      service_account_role_arn = module.ebs_csi_driver_irsa.iam_role_arn
    }
  }

  depends_on = [
    module.eks,
    module.ebs_csi_driver_irsa
  ]
}

resource "helm_release" "kubecost" {
  name       = "kubecost"
  namespace = "kubecost"  # 원하는 네임스페이스로 수정
  chart      = "kubecost/cost-analyzer"
  version    = "2.3.3"  # Helm 차트 버전
   repository = "oci://public.ecr.aws/kubecost"
#   chart      = "cost-analyzer"
#   version = "2.7.0"  # 원하는 Helm 차트 버전으로 설정

  create_namespace = true  # 네임스페이스가 없으면 생성

  depends_on = [
    module.eks,
    module.eks_blueprint_aws_addons_aws_ebs_csi_driver
  ]
}