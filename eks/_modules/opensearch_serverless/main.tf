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

resource "aws_opensearchserverless_vpc_endpoint" "this" {
  name       = "${var.name}-vpce"
  subnet_ids = var.subnet_ids
  vpc_id     = var.vpc_id
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
