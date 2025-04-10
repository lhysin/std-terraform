output "eks_kubeconfig_update_command" {
  description = "Command to update kubeconfig for EKS cluster"
  value = "aws eks --region ${var.region} update-kubeconfig --name ${module.eks.cluster_name}"
}

output "argocd_admin_password" {
  description = "Command to get the ArgoCD initial admin password"
  value       = "kubectl get secret -n argocd argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 --decode"
}