resource "helm_release" "kubecost" {
  name       = "kubecost"
  namespace  = "kubecost"  # 원하는 네임스페이스로 수정
  repository = "https://kubecost.github.io/cost-analyzer"
  chart      = "cost-analyzer"
  version    = "2.7.0"  # 원하는 Helm 차트 버전으로 설정

  create_namespace = true  # 네임스페이스가 없으면 생성

  depends_on = [
    module.eks,
    module.mgmt_eks_blueprints_addons
  ]
}