output "eks_cluster_name" {
  value = aws_eks_cluster.this.name
}

output "eks_cluster_arn" {
  value = aws_eks_cluster.this.arn
}

output "cluster_security_group_ids" {
  value = [for vpc_config in aws_eks_cluster.this.vpc_config : vpc_config.cluster_security_group_id]
}

output "eks_oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.this.arn
}

output "eks_version" {
  value = aws_eks_cluster.this.version
}
