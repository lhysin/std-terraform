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

output "cluster_primary_security_group_id" {
  description = "Cluster security group that was created by Amazon EKS for the cluster. Managed node groups use this security group for control-plane-to-data-plane communication. Referred to as 'Cluster security group' in the EKS console"
  value = module.eks.cluster_primary_security_group_id
}

output "node_security_group_id" {
  description = "ID of the node shared security group"
  value = module.eks.node_security_group_id
}