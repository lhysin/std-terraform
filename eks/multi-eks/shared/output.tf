output "vpc_id" {
  description = "The ID of the Default VPC"
  value       = module.vpc.vpc_id
}

# output "public_subnets" {
#   description = "List of IDs of public subnets for primary and secondary clusters"
#   value = {
#     # pri : a-pub-1, b-pub-1
#     # sec : a-pub-2, b-pub-2
#     pri = [module.vpc.public_subnets[0], module.vpc.public_subnets[1]]
#     sec = [module.vpc.public_subnets[2], module.vpc.public_subnets[3]]
#   }
# }
#
# output "private_subnets" {
#   description = "List of IDs of private subnets for primary and secondary clusters"
#   value = {
#     pri = [module.vpc.private_subnets[0], module.vpc.private_subnets[1]]
#     sec = [module.vpc.private_subnets[2], module.vpc.private_subnets[3]]
#   }
# }

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

output "public_subnet_cidr_blocks" {
  description = "List of public subnet cidr blocks for the Public Subnets"
  value       = module.vpc.public_subnet_cidr_blocks
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}

output "private_subnet_cidr_blocks" {
  description = "List of public subnet cidr blocks for the Private Subnets"
  value       = module.vpc.private_subnet_cidr_blocks
}

output "cluster_sg_id" {
  description = "The ID of the cluster security group."
  value       = module.eks_sg.cluster_sg_id
}

output "alb_ingress_sg_id" {
  description = "The ID of the security group associated with the Application Load Balancer (ALB) ingress."
  value       = module.eks_sg.alb_ingress_sg_id
}

output "alb_cjenm_only_ingress_sg_id" {
  description = "The ID of the security group for the ALB ingress, restricted to CJENM-specific traffic."
  value       = module.eks_sg.alb_cjenm_only_ingress_sg_id
}

# output "service_alb_arn" {
#   description = "Service Application Load Balancer ARN"
#   # alb : a-pub-1, b-pub-1
#   value       = module.alb.arn
# }