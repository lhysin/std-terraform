output "vpc_id" {
  description = "The ID of the Default VPC"
  value       = module.vpc.vpc_id
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value = module.vpc.public_subnets
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value = module.vpc.private_subnets
}

output "intra_subnets" {
  description = "List of IDs of intra subnets"
  value = module.vpc.intra_subnets
}

output "service_alb_arn" {
  description = "Service Application Load Balancer ARN"
  value = module.alb.arn
}