output "vpc_id" {
  description = "The ID of the VPC"
  value       = var.vpc_id
}

output "public_subnet_ids" {
  description = "A list of all public subnets, containing the full objects."
  value       = [for subnet in aws_subnet.public : subnet.id]
}

output "public_route_table_id" {
  description = "The ID of the public route table"
  value       = var.public_route_table_id
}

output "private_subnet_ids" {
  description = "A list of all private subnets, containing the full objects."
  value       = [for subnet in aws_subnet.private : subnet.id]
}


output "private_route_table_id" {
  description = "The ID of the private route table"
  value       = var.private_route_table_id
}
