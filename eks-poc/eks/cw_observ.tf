resource "aws_eks_addon" "example" {
  cluster_name = aws_eks_cluster.eks.name
  addon_name   = "amazon-cloudwatch-observability"

#   configuration_values = jsonencode({
#     enable_application_signals = "true"
#   })

  service_account_role_arn = aws_iam_role.cloudwatch_addon_role.arn

  tags = local.cj_enm_tag
}

resource "aws_iam_role" "cloudwatch_addon_role" {
  name = "CloudWatchAddonRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cloudwatch_policy_attachment" {
  role       = aws_iam_role.cloudwatch_addon_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"  # 관리형 정책
}

resource "aws_iam_role_policy_attachment" "cloudwatch_logs_policy_attachment" {
  role       = aws_iam_role.cloudwatch_addon_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}