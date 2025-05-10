output "eks_cluster_name" {
  value = module.eks.eks_cluster_name
}

output "eks_cluster_arn" {
  value = module.eks.eks_cluster_arn
}

output "target_group_arn" {
  value = module.eks_alb.target_group_arn
}

output "aws_lbc_role_name" {
  value = module.aws_lbc_role.role_name
}

output "aws_lbc_role_arn" {
  value = module.aws_lbc_role.role_arn
}

output "aws_lbc_ns" {
  value = module.aws_lbc_role.namespace
}

output "aws_lbc_sa" {
  value = module.aws_lbc_role.service_account_name
}

output "eks_oidc_provider_arn" {
  value = module.eks.eks_oidc_provider_arn
}

# output "opensearch_endpoint" {
#   value = module.opensearch.opensearch_endpoint
# }

# output "opensearch_dashboard_endpoint" {
#   value = module.opensearch.opensearch_dashboard_endpoint
# }
