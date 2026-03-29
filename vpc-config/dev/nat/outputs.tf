output "instance_id" {
  description = "The ID of the NAT instance"
  value       = module.nat.instance_id
}

output "route_id" {
  description = "The ID of the route table entry"
  value       = module.nat.route_id
}

output "security_group_id" {
  description = "The ID of the security group"
  value       = module.nat.security_group_id
}
