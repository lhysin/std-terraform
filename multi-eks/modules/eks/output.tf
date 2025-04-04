output "cluster_name" {
  value = module.eks.cluster_name
  description = "Name of the EKS cluster"
}

output "host" {
  description = "Endpoint for your Kubernetes API server"
  value =  module.eks.cluster_endpoint
}

output "token" {
  description = "Token for EKS Cluster Auth"
  value = data.aws_eks_cluster_auth.cluster_auth.token
}

output "ca_certificate" {
  description = "Certificate data required to communicate with the cluster"
  value = base64decode(module.eks.cluster_certificate_authority_data)
}

output "cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server"
  value       = module.eks.cluster_endpoint
}

output "cluster_version" {
  description = "The Kubernetes version for the cluster"
  value       = module.eks.cluster_version
}

output "oidc_provider_arn" {
  description = "The ARN of the OIDC Provider if `enable_irsa = true`"
  value       = module.eks.oidc_provider_arn
}