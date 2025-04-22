output "eks_cluster_name" {
  value = module.eks.eks_cluster_name
}

output "target_group_arn" {
  value = module.eks_alb.target_group_arn
}

output "aws_lbc_role_name" {
  value = module.role_for_sa.role_name
}

output "aws_lbc_role_arn" {
  value = module.role_for_sa.role_arn
}

output "aws_lbc_ns" {
  value = module.role_for_sa.namespace
}

output "aws_lbc_sa" {
  value = module.role_for_sa.service_account_name
}

output "opensearch_endpoint" {
  value = module.opensearch_serverless.opensearch_endpoint
}

output "opensearch_dashboard_endpoint" {
  value = module.opensearch_serverless.opensearch_dashboard_endpoint
}
