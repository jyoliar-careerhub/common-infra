output "opensearch_endpoint" {
  value = aws_opensearchserverless_collection.this.collection_endpoint
}

output "opensearch_dashboard_endpoint" {
  value = aws_opensearchserverless_collection.this.dashboard_endpoint
}

output "opensearch_collection_arn" {
  value = aws_opensearchserverless_collection.this.arn
}
