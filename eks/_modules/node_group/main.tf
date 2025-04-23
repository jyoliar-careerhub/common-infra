# Launch Template 생성
resource "aws_launch_template" "eks_worker" {
  name_prefix = "${var.name}-"

  network_interfaces {
    security_groups = concat([aws_security_group.eks_node.id, ], var.cluster_security_group_ids)
  }
}

resource "aws_eks_node_group" "careerhub" {
  cluster_name  = var.cluster_name
  node_role_arn = aws_iam_role.node_group.arn
  subnet_ids    = var.subnet_ids

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  instance_types = var.instance_types
  ami_type       = var.ami_type
  version        = var.eks_version

  update_config {
    max_unavailable = var.update_config
  }

  launch_template {
    id      = aws_launch_template.eks_worker.id
    version = "1"
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}

resource "aws_iam_role" "node_group" {
  name = "${var.name}-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node_group.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node_group.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node_group.name
}

#ssm 정책 추가
resource "aws_iam_role_policy_attachment" "AmazonSSMManagedInstanceCore" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.node_group.name
}
#이 정책은 위의 AmazonEC2ContainerRegistryReadOnly 정책과 동일한 권한을 가지는 것으로 보입니다.
#검토 후 삭제하겠습니다.
data "aws_iam_policy_document" "ecr_readonly" {
  statement {
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetAuthorizationToken"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "ecr_readonly" {
  name   = "${var.name}-ecr-readonly"
  role   = aws_iam_role.node_group.name
  policy = data.aws_iam_policy_document.ecr_readonly.json
}

data "aws_vpc" "this" {
  id = var.vpc_id
}

# # EKS 노드 그룹 보안 그룹
resource "aws_security_group" "eks_node" {
  name        = "${var.name}-sg"
  description = "Security group for EKS Worker Nodes"
  vpc_id      = var.vpc_id
}

resource "aws_security_group" "allowed_alb" {
  name   = "${var.name}-allowed-alb-sg"
  vpc_id = var.vpc_id
}

resource "aws_security_group_rule" "allow_from_alb" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.eks_node.id
  source_security_group_id = aws_security_group.allowed_alb.id
}
