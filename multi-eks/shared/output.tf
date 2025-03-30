output "vpc_id" {
  description = "The ID of the Default VPC"
  value       = module.vpc.vpc_id
}

output "public_subnets" {
  description = "List of IDs of public subnets for primary and secondary clusters"
  value = {
    # pri : a-pub-1, b-pub-1
    # sec : a-pub-2, b-pub-2
    pri = [module.vpc.public_subnets[0], module.vpc.public_subnets[1]]
    sec = [module.vpc.public_subnets[2], module.vpc.public_subnets[3]]
  }
}

output "private_subnets" {
  description = "List of IDs of private subnets for primary and secondary clusters"
  value = {
    pri = [module.vpc.private_subnets[0], module.vpc.private_subnets[1]]
    sec = [module.vpc.private_subnets[2], module.vpc.private_subnets[3]]
  }
}

output "intra_subnets" {
  description = "List of IDs of intra subnets for primary and secondary clusters"
  value = {
    pri = [module.vpc.intra_subnets[0], module.vpc.intra_subnets[1]]
    sec = [module.vpc.intra_subnets[2], module.vpc.intra_subnets[3]]
  }
}

output "service_alb_arn" {
  description = "Service Application Load Balancer ARN"
  # alb : a-pub-1, b-pub-1
  value       = module.alb.arn
}