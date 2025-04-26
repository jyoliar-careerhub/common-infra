output "opensearch_arn" {
  value = aws_opensearch_domain.this.arn
}

output "opensearch_endpoint" {
  value = aws_opensearch_domain.this.endpoint_v2
}

output "opensearch_dashboard_endpoint" {
  value = aws_opensearch_domain.this.dashboard_endpoint_v2
}
