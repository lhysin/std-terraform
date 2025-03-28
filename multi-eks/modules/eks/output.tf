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