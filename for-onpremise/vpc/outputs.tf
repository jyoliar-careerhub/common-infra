# VPC Outputs
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "public_route_table_id" {
  description = "The ID of the public route table"
  value       = module.vpc.public_route_table_id
}

output "private_route_table_id" {
  description = "The ID of the private route table"
  value       = module.vpc.private_route_table_id
}

# Core Subnets Outputs
output "core_public_subnet_ids" {
  description = "A list of all core public subnets"
  value       = module.core_subnets.public_subnet_ids
}

output "core_private_subnet_ids" {
  description = "A list of all core private subnets"
  value       = module.core_subnets.private_subnet_ids
}

# EKS Subnets Outputs
output "eks_public_subnet_ids" {
  description = "A list of all eks public subnets"
  value       = module.eks_subnets.public_subnet_ids
}

output "eks_private_subnet_ids" {
  description = "A list of all eks private subnets"
  value       = module.eks_subnets.private_subnet_ids
}
