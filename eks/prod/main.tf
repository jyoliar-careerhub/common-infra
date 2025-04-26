locals {
  node_group = {
    "app" = {
      ng_name        = "ng-app"
      min_size       = 2
      max_size       = 2
      desired_size   = 2
      instance_types = ["t4g.medium"]
      ami_type       = "AL2023_ARM_64_STANDARD"
    }
    # "monitoring" = {
    #   ng_name        = "ng-monitoring"
    #   min_size       = 1
    #   max_size       = 1
    #   desired_size   = 1
    #   instance_types = ["t4g.medium"]
    #   ami_type       = "AL2023_ARM_64_STANDARD"
    # }
  }
}


module "eks" {
  source = "../_modules/eks"

  name       = "${var.env}-eks"
  subnet_ids = local.eks_subnets_outputs.public_subnet_ids
  vpc_id     = local.eks_subnets_outputs.vpc_id
}


module "node_group" {
  source = "../_modules/node_group"

  for_each = local.node_group

  vpc_id                     = local.eks_subnets_outputs.vpc_id
  subnet_ids                 = local.eks_subnets_outputs.public_subnet_ids
  cluster_name               = module.eks.eks_cluster_name
  eks_version                = module.eks.eks_version
  cluster_security_group_ids = module.eks.cluster_security_group_ids

  name           = "${var.env}-${each.value.ng_name}"
  min_size       = each.value.min_size
  max_size       = each.value.max_size
  desired_size   = each.value.desired_size
  instance_types = each.value.instance_types
  ami_type       = each.value.ami_type
}


data "aws_caller_identity" "terraform" {}

data "aws_iam_role" "terraform" {
  name = element(split("/", data.aws_caller_identity.terraform.arn), 1)
}

module "eks_access" {
  source = "../_modules/eks_access"

  cluster_name = module.eks.eks_cluster_name

  cluster_admin_arns = concat(var.cluster_admin_arns, [data.aws_iam_role.terraform.arn])
}

data "aws_acm_certificate" "issued" {
  domain   = var.acm_cert_domain
  statuses = ["ISSUED"]
}

module "eks_alb" {
  source = "../_modules/alb"

  name               = "${var.env}-eks-alb"
  vpc_id             = local.eks_subnets_outputs.vpc_id
  subnet_ids         = local.eks_subnets_outputs.public_subnet_ids
  certificate_arn    = data.aws_acm_certificate.issued.arn
  security_group_ids = [for node_group in module.node_group : node_group.allowed_alb_sg_id]

  health_check_path = "/livez"
  is_internal       = false
  is_https          = true
  is_ssl_redirect   = true
  allow_access_all  = true
}

data "aws_route53_zone" "this" {
  name = var.hosted_zone_name
}

resource "aws_route53_record" "alb_record" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = var.alb_domain
  type    = "A"

  alias {
    name                   = module.eks_alb.alb_dns_name
    zone_id                = module.eks_alb.alb_zone_id
    evaluate_target_health = true
  }
}


### # AWS Load Balancer Controller
data "http" "aws_lbc_policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.11.0/docs/install/iam_policy.json"
}

resource "aws_iam_policy" "aws_lbc" {
  name        = "AWSLoadBalancerControllerIAMPolicy"
  description = "IAM policy for AWS Load Balancer Controller"

  policy = data.http.aws_lbc_policy.body
}

module "aws_lbc_role" {
  source = "../_modules/pod_identity"

  name                 = "${var.env}-aws-lbc"
  cluster_arn          = module.eks.eks_cluster_arn
  namespace            = var.aws_lbc_ns
  service_account_name = var.aws_lbc_sa
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = module.aws_lbc_role.role_name
  policy_arn = aws_iam_policy.aws_lbc.arn
}

#반복적인 인프라 생성/제거 과정에서 저장된 비밀키가 삭제되는 경우가 발생하여 외부 생성으로 변경
data "aws_ssm_parameter" "argocd_private_key" {
  name = "${var.env}-argocd-private-key"
}

resource "aws_iam_policy" "argocd-repo-reader" {
  name = "${var.env}-argocd-repo-reader"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowSpecificSecret"
        Effect = "Allow"
        Action = [
          "ssm:GetParameter*"
        ]

        Resource = [
          data.aws_ssm_parameter.argocd_private_key.arn
        ]
      }
    ]
  })
}

module "eks_secrets_provider_role" {
  source = "../_modules/role_for_sa"

  name                  = "${var.env}-argocd-repo-reader"
  eks_oidc_provider_arn = module.eks.eks_oidc_provider_arn
  namespace             = "argocd"
  service_account_name  = "argocd-repo-reader"
}




resource "aws_iam_role_policy_attachment" "argocd-repo-reader" {
  role       = module.eks_secrets_provider_role.role_name
  policy_arn = aws_iam_policy.argocd-repo-reader.arn
}


#opensearch
# module "opensearch" {
#   source = "../_modules/opensearch"

#   name       = "${var.env}-eks-logs-opensearch"
#   subnet_ids = local.eks_subnets_outputs.public_subnet_ids[0]
#   vpc_id     = local.eks_subnets_outputs.vpc_id

#   instance_type  = "t2.micro.search"
#   instance_count = 1
#   engine_version = "Elasticsearch_2.3"

#   volume_size = 10
# }

module "fluentbit_opensearch_role" {

  source = "../_modules/pod_identity"

  name                 = "${var.env}-fluentbit_opensearch_role"
  cluster_arn          = module.eks.eks_cluster_arn
  namespace            = "kube-logs"
  service_account_name = "fluentbit-opensearch-role"
}

module "opensearch" {
  source = "../_modules/opensearch"

  name       = "${var.env}-eks-logs"
  subnet_ids = [local.eks_subnets_outputs.public_subnet_ids[0]]
  vpc_id     = local.eks_subnets_outputs.vpc_id

  engine_version = "OpenSearch_2.17"
  instance_type  = "t3.small.search"
  volume_size    = 10
  instance_count = 1
}

data "aws_iam_policy_document" "index_permission" {
  statement {
    effect  = "Allow"
    actions = ["es:ESHttpPatch", "es:ESHttpPut", "es:ESHttpPost"]

    resources = [module.opensearch.opensearch_arn]
  }
}

resource "aws_iam_policy" "index_permission" {
  name        = "${var.env}-eks-es"
  description = "Index permission policy for OpenSearch"
  policy      = data.aws_iam_policy_document.index_permission.json
}

resource "aws_iam_role_policy_attachment" "index_permission" {
  policy_arn = aws_iam_policy.index_permission.arn
  role       = module.fluentbit_opensearch_role.role_name
}
