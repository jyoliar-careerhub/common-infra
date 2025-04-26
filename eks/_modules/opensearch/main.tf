data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "example" {
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = var.admin_principal_arns
    }

    actions   = ["es:*"]
    resources = ["arn:aws:es:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:domain/${var.name}/*"]
  }
}




resource "aws_opensearch_domain" "this" {
  domain_name    = var.name
  engine_version = var.engine_version


  cluster_config {
    instance_type  = var.instance_type
    instance_count = 1
  }


  ebs_options {
    ebs_enabled = true
    volume_size = var.volume_size
  }

  access_policies = data.aws_iam_policy_document.example.json
}
