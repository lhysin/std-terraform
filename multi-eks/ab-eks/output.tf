# output "eks_kubeconfig_update_command" {
#   value = "aws eks --region ${var.region} update-kubeconfig --name ${module.ab_cluster.cluster_name}"
#   description = "Command to update kubeconfig for EKS cluster"
# }