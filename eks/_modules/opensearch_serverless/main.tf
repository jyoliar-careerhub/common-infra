resource "aws_opensearchserverless_security_policy" "this" {
  name = "${var.name}-encryption"
  type = "encryption"
  policy = jsonencode({
    "Rules" = [
      {
        "Resource" = [
          "collection/${var.name}"
        ],
        "ResourceType" = "collection"
      }
    ],
    "AWSOwnedKey" = true
  })
}

resource "aws_opensearchserverless_collection" "this" {
  name = var.name

  depends_on = [aws_opensearchserverless_security_policy.this]
}


resource "aws_security_group" "this" {
  name   = "${var.name}-sg"
  vpc_id = var.vpc_id
}

data "aws_subnet" "this" {
  for_each = toset(var.subnet_ids)
  id       = each.value
}

resource "aws_security_group_rule" "allow_subnets" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.this.id
  cidr_blocks       = [for subnet in data.aws_subnet.this : subnet.cidr_block]
}

resource "aws_security_group_rule" "allow_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.this.id
  cidr_blocks       = ["0.0.0.0/0"] # Allow all outbound traffic
}

# resource "aws_security_group_rule" "allow_all_egress" {
#   type              = "egress"
#   from_port         = 0
#   to_port           = 0
#   protocol          = "-1"
#   security_group_id = aws_security_group.this.id
#   cidr_blocks       = ["0.0.0.0/0"]
# }

resource "aws_opensearchserverless_vpc_endpoint" "this" {
  name       = "${var.name}-vpce"
  subnet_ids = var.subnet_ids
  vpc_id     = var.vpc_id

  security_group_ids = concat([aws_security_group.this.id], var.security_group_ids)
}


resource "aws_opensearchserverless_security_policy" "dashboard" {
  name        = "${var.name}-access-dashboard"
  type        = "network"
  description = "Public access"
  policy = jsonencode([
    {
      Description = "Public access to collection and Dashboards endpoint for example collection",
      Rules = [
        {
          ResourceType = "dashboard"
          Resource = [
            "collection/${aws_opensearchserverless_collection.this.name}"
          ]
        }
      ],
      AllowFromPublic = true
    }
  ])
}

resource "aws_opensearchserverless_security_policy" "collection" {
  name        = "${var.name}-access-collection"
  type        = "network"
  description = "VPC access"
  policy = jsonencode([
    {
      Description = "VPC access to collection and Dashboards endpoint for example collection",
      Rules = [
        {
          ResourceType = "collection",
          Resource = [
            "collection/${aws_opensearchserverless_collection.this.name}"
          ]
        },
      ],
      AllowFromPublic = false,
      SourceVPCEs = [
        aws_opensearchserverless_vpc_endpoint.this.id
      ]
    }
  ])
}


resource "aws_opensearchserverless_access_policy" "admin" {
  name = "${var.name}-admin"
  type = "data"

  policy = jsonencode([
    {
      Rules = [
        {
          ResourceType = "index",
          Resource = [
            "index/${aws_opensearchserverless_collection.this.name}/*"
          ],
          Permission = [
            "aoss:*"
          ]
        },
        {
          ResourceType = "collection",
          Resource = [
            "collection/${aws_opensearchserverless_collection.this.name}"
          ],
          Permission = [
            "aoss:*"
          ]
        }
      ],
      Principal = var.admin_principal_arns,
    }
  ])
}


resource "aws_opensearchserverless_access_policy" "index_permission" {
  name = "${var.name}-index-permission"
  type = "data"

  policy = jsonencode([
    {
      Rules = [
        {
          ResourceType = "index",
          Resource = [
            "index/${aws_opensearchserverless_collection.this.name}/*"
          ],
          Permission = [
            "aoss:*"
          ]
        }
      ],
      Principal = var.index_permission_principal_arns,
    }
  ])
}
