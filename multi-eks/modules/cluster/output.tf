output "cluster_name" {
  value = module.eks.cluster_name
  description = "EKS cluster name"
}

output "host" {
  description = "Endpoint for your Kubernetes API server"
  value =  module.eks.host
}

output "token" {
  description = "Token for EKS Cluster Auth"
  value = module.eks.token
}

output "ca_certificate" {
  description = "Certificate data required to communicate with the cluster"
  value = module.eks.ca_certificate
}