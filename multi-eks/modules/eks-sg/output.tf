output "cluster_sg_id" {
  description = "The ID of the cluster security group."
  value       = module.cluster_sg.security_group_id
}

output "alb_ingress_sg_id" {
  description = "The ID of the security group associated with the Application Load Balancer (ALB) ingress."
  value       = module.alb_ingress_sg.security_group_id
}

output "alb_cjenm_only_ingress_sg_id" {
  description = "The ID of the security group for the ALB ingress, restricted to CJENM-specific traffic."
  value       = module.alb_cjenm_only_ingress_sg.security_group_id
}