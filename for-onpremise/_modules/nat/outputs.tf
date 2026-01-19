output "instance_id" {
  description = "The ID of the NAT instance"
  value       = aws_instance.nat.id
}

output "route_id" {
  description = "The ID of the route table entry"
  value       = aws_route.nat_gateway.id
}

output "security_group_id" {
  description = "The ID of the security group"
  value       = aws_security_group.nat_instance_sg.id
}
