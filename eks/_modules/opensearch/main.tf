
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
  from_port         = 9200
  to_port           = 9200
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




resource "aws_opensearch_domain" "this" {
  domain_name    = var.name
  engine_version = var.engine_version


  cluster_config {
    instance_type          = var.instance_type #t3 is not supported by auto-tune.
    zone_awareness_enabled = true
    zone_awareness_config {
      availability_zone_count = 3
    }
    instance_count = 1
  }

  # IF YOU WANT VPC access.
  vpc_options {
    subnet_ids         = var.subnet_ids
    security_group_ids = concat([aws_security_group.this.id], var.security_group_ids)
  }

  # advanced_security_options {
  #   enabled                        = false
  #   anonymous_auth_enabled         = true
  #   internal_user_database_enabled = true
  #   master_user_options {
  #     master_user_name     = "admin"
  #     master_user_password = "TestMasterPassword123!@#"
  #   }
  # }
}
