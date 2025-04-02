output "vpc_name" {
  description = "The Name of the Default VPC"
  value       = module.vpc.name
}

output "vpc_id" {
  description = "The ID of the Default VPC"
  value       = module.vpc.vpc_id
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}

output "intra_subnets" {
  description = "List of IDs of intra subnets"
  value       = module.vpc.intra_subnets
}

output "default_route_table_id" {
  description = "default route table of the created VPC"
  value       = module.vpc.default_route_table_id
}

output "default_vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.default_vpc_cidr_block
}

output "azs" {
  description = "A list of availability zones specified as argument to this module"
  value = module.vpc.azs
}
