output "phase" {
  value = var.phase
}

output "region" {
  value = var.region
}

output "eks_cli" {
  value = "aws eks --region ${var.region} update-kubeconfig --name ${aws_eks_cluster.eks.name}"
}

output "eks_cluster_endpoint" {
  value = aws_eks_cluster.eks.endpoint
}

output "kubectl_config_for_aws" {
  value = "aws eks --region ${var.region} update-kubeconfig --name ${aws_eks_cluster.eks.name}"
}