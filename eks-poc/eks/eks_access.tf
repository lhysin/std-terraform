# AWS IAM 사용자 정보를 가져오는 데이터 소스 정의
# `for_each`를 사용하여 `var.eks_admin_ids` 목록에 있는 각 사용자에 대한 정보를 동적으로 조회
data "aws_iam_user" "users" {
  for_each  = toset(var.eks_admin_ids)  # 리스트를 Set 자료형으로 변환하여 중복 제거
  user_name = each.value  # 각 IAM 사용자 이름을 가져옴
}

# EKS 액세스 엔트리를 생성하는 리소스
# 각 IAM 사용자에 대해 EKS 클러스터에 대한 접근 권한을 설정
resource "aws_eks_access_entry" "eks_access_entry" {
  for_each         = data.aws_iam_user.users  # IAM 사용자 수만큼 리소스 생성
  cluster_name     = aws_eks_cluster.eks.name  # 대상 EKS 클러스터 이름
  principal_arn    = each.value.arn  # IAM 사용자의 ARN을 principal_arn으로 지정
  kubernetes_groups = ["eks-admins"]  # EKS 클러스터 내에서 "eks-admins" 그룹에 할당
  type             = "STANDARD"  # 표준 액세스 유형 (STANDARD)

  depends_on = [data.aws_iam_user.users]  # IAM 사용자 정보가 먼저 조회된 후 실행되도록 설정
}

# EKS 액세스 정책을 IAM 사용자와 연결하는 리소스
# 각 IAM 사용자에 대해 클러스터 액세스 정책을 적용하여 관리 권한을 부여
resource "aws_eks_access_policy_association" "eks_access_policy_association" {
  for_each     = data.aws_iam_user.users  # IAM 사용자 수만큼 리소스를 생성
  cluster_name = aws_eks_cluster.eks.name  # 대상 EKS 클러스터 이름
  policy_arn   = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"  # EKS 클러스터 관리 정책 (Admin 권한)
  principal_arn = each.value.arn  # IAM 사용자의 ARN을 principal_arn으로 지정

  # 정책이 적용될 액세스 범위 설정
  access_scope {
    type = "cluster"  # 클러스터 전체에 대한 액세스 권한을 부여
  }

  # 특정 네임스페이스에 대한 정책을 적용하려면 아래 코드의 주석을 해제하고 수정 가능
  # access_scope {
  #   type       = "namespace"
  #   namespaces = ["ingress-nginx"]  # 특정 네임스페이스에 대한 정책 적용 가능
  # }

  depends_on = [aws_eks_access_entry.eks_access_entry]  # 액세스 엔트리가 먼저 생성된 후 실행되도록 설정
}