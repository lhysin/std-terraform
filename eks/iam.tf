# EKS 클러스터 역할 (IAM 역할)
resource "aws_iam_role" "eks_cluster_role" {
  name = "${local.service_prefix}-eks-cluster-role-${local.service_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })

  tags = merge(local.cj_enm_tag, {
    Name = "${local.service_prefix}-eks-cluster-role-${local.service_name}"
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_role_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

# EKS 워커 노드 IAM 역할
resource "aws_iam_role" "eks_node_role" {
  name = "${local.service_prefix}-eks-node-role-${local.service_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = merge(local.cj_enm_tag, {
    Name = "${local.service_prefix}-eks-node-role-${local.service_name}"
  })
}

resource "aws_iam_role_policy_attachment" "eks_node_role_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_node_role_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_node_role_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_node_role_AutoScalingFullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AutoScalingFullAccess"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role" "eks_fargate_role" {
  name = "${local.service_prefix}-eks-fargate-role-${local.service_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "eks-fargate-pods.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = local.cj_enm_tag
}

resource "aws_iam_role_policy_attachment" "eks_fargate_role_AmazonEKSFargatePodExecutionRolePolicy" {
  role       = aws_iam_role.eks_fargate_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
}