# EKS 클러스터 생성
resource "aws_eks_cluster" "eks" {
  name     = "${local.service_prefix}-eks-cluster-${local.service_name}"

  access_config {
    # CONFIG_MAP, API, API_AND_CONFIG_MAP
    authentication_mode = "API"
    # default false
    bootstrap_cluster_creator_admin_permissions = false
  }

  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = var.k8s_version

  vpc_config {
    subnet_ids = [
      aws_subnet.public-a.id,
      aws_subnet.public-b.id,
      aws_subnet.private-a.id,
      aws_subnet.private-b.id
    ]
    endpoint_public_access = true
    endpoint_private_access = false
  }

  enabled_cluster_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  # Ensure that IAM Role permissions are created before and deleted
  # after EKS Cluster handling. Otherwise, EKS will not be able to
  # properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_role_AmazonEKSClusterPolicy,
  ]

  tags = local.cj_enm_tag
}

resource "aws_eks_node_group" "eks_t4g_small_node_group" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "${local.service_prefix}-node-group-t4g-small-${local.service_name}"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = [
    aws_subnet.public-a.id,
    aws_subnet.public-b.id,
    aws_subnet.private-a.id,
    aws_subnet.private-b.id
  ]

  version = var.k8s_version
  release_version = ""

  scaling_config {
    desired_size = 1
    max_size     = 8
    min_size     = 1
  }

  # ON_DEMAND : 항상 사용
  # SPOT : 유휴 자원
  capacity_type   = "SPOT"
  instance_types = ["t4g.medium"]
  ami_type       = "AL2_ARM_64"

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.eks_node_role_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks_node_role_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks_node_role_AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.eks_node_role_AutoScalingFullAccess,
  ]

  tags = local.cj_enm_tag
}

# Fargate Profile 추가
# fargate 는 arm을 지원하지 않음
#   https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/fargate.html
resource "aws_eks_fargate_profile" "fargate_profile" {
  cluster_name           = aws_eks_cluster.eks.name
  fargate_profile_name   = "${local.service_prefix}-fargate-profile-${local.service_name}"
  pod_execution_role_arn = aws_iam_role.eks_fargate_role.arn
  subnet_ids = [
    aws_subnet.private-a.id,
    aws_subnet.private-b.id
  ]

  # fargate 의 경우 네임스페이스 단위로 구성
  selector {
    namespace = "${var.phase}-fargate"
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_fargate_role_AmazonEKSFargatePodExecutionRolePolicy
  ]

  tags = local.cj_enm_tag
}