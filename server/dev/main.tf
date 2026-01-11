locals {
  cpu2mem2 = "t4g.small"
  cpu2mem4 = "t4g.medium"
  cpu2mem8 = "t4g.large"
  ubuntu24 = "ami-027308df79a86d22c" #Ubuntu 24.04 LTS

  instances = {
    "ansible-server" = {
      role          = "ansible-server"
      instance_type = local.cpu2mem2
      ami           = local.ubuntu24
      subnet_id     = local.eks_subnets_outputs.public_subnet_ids[0]
    }
    "k8s-master-0" = {
      role          = "master"
      instance_type = local.cpu2mem8
      ami           = local.ubuntu24
      subnet_id     = local.eks_subnets_outputs.private_subnet_ids[0]
      private_ip    = "10.0.25.101"
    }
    "k8s-master-1" = {
      role          = "master"
      instance_type = local.cpu2mem8
      ami           = local.ubuntu24
      subnet_id     = local.eks_subnets_outputs.private_subnet_ids[0]
      private_ip    = "10.0.25.102"
    }
    "k8s-master-2" = {
      role          = "master"
      instance_type = local.cpu2mem8
      ami           = local.ubuntu24
      subnet_id     = local.eks_subnets_outputs.private_subnet_ids[0]
      private_ip    = "10.0.25.103"
    }
    "k8s-worker-0" = {
      role          = "worker"
      instance_type = local.cpu2mem8
      ami           = local.ubuntu24
      subnet_id     = local.eks_subnets_outputs.private_subnet_ids[0]
      private_ip    = "10.0.25.104"
    }
  }
}

resource "aws_security_group" "this" {
  name   = "ansible-server-sg"
  vpc_id = local.eks_subnets_outputs.vpc_id
}

resource "aws_security_group_rule" "ingress" {
  type              = "ingress"
  from_port         = 1
  to_port           = 65535
  protocol          = "-1"
  security_group_id = aws_security_group.this.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.this.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_key_pair" "this" {
  key_name   = "k8s-node-server"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDMX2GVbPKMl/ZORgK/LHdpd9LFKK1m5sLy+UER11RNXsu8GpDFkXfGibf4QrYCSznTtA/2+3VyEPY3zEfXJmaUbZ6Ynk9zH1c8L8IFyeChQC+eMJKgDIh/7vI6msVRCJY3uqFdtswvcoSQNrFV8QCfTOTCWIt9Mlnar484a0dW3hJoPipTCTRvU9peMB+3wHJ5LevY5LUgfc6tAVFj+g4DZs3W9Fvz6ZsbGD+Uk27ttTgqrxaPuGvTsJmC4cSrfKq9VUdaEsgAmgZrZNOOr2FAScTuqzclIB8jF47MZ3oCKxUClr93RAb/rtKXqzMGCnOQQDZg9BXp5cFS6OUGX6mmBIYIEnmkTsK7m3s29A7qr4CtPE6kWvkxC4zT/zcrAvNLXzytIbJMGkIlY0cMkyf/v75fZHmhYEEm7j7pI7YEAvL2Xmoshso17y4g8goPsewUbaC5mjcFB2I9g4+bgZVWbAAVKU+OuuHdT3pJWaeDjpfOZKTrywo2uN/FqjIDgC46aXKyubi5z/wmBtxI6qe+ChI43g15MeRTasU7Oe2XdyjNwkbNVCiw5LWqunbQq06GpFKsTo9apH2o+d2s9jGV2lKeMgzFKJ8PfPg+LUuTcJOVZ36LQVRfOAAhkX30GXlkFgRNI0GR72n5CAdd6CB5znNBzNTtltXxLyTO8rLAHw=="
}

resource "aws_instance" "this" {
  for_each               = local.instances
  ami                    = each.value.ami
  instance_type          = each.value.instance_type
  subnet_id              = each.value.subnet_id
  key_name               = aws_key_pair.this.key_name
  vpc_security_group_ids = [aws_security_group.this.id]

  private_ip = try(each.value.private_ip, null)

  tags = {
    Name = each.key
  }

  user_data = try(each.value.user_data, null)
}

data "aws_route53_zone" "this" {
  name = var.hosted_zone_name
}

resource "aws_route53_record" "ansible" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = var.server_domain
  type    = "A"
  ttl     = 300
  records = [aws_instance.this["ansible-server"].public_ip]
}


resource "aws_lb" "api-endpoint-nlb" {
  name               = "k8s-api-endpoint-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = local.eks_subnets_outputs.public_subnet_ids

  enable_deletion_protection = false

  tags = {
    Environment = "production"
  }
}

resource "aws_lb_target_group" "api-endpoint-nlb-tg" {
  name        = "k8s-api-endpoint-nlb-tg"
  vpc_id      = local.eks_subnets_outputs.vpc_id
  protocol    = "TCP"
  port        = 6443
  target_type = "instance"
}

resource "aws_lb_listener" "api-endpoint-nlb-listener" {
  load_balancer_arn = aws_lb.api-endpoint-nlb.arn
  port              = 6443
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api-endpoint-nlb-tg.arn
  }
}

resource "aws_lb_target_group_attachment" "api-endpoint-nlb-tg-attachment" {
  for_each         = { for k, v in local.instances : k => v if v.role == "master" }
  target_group_arn = aws_lb_target_group.api-endpoint-nlb-tg.arn
  target_id        = aws_instance.this[each.key].id
  port             = 6443
}

resource "aws_route53_record" "k8s_api" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = var.k8s_api_domain
  type    = "A"

  alias {
    name                   = aws_lb.api-endpoint-nlb.dns_name
    zone_id                = aws_lb.api-endpoint-nlb.zone_id
    evaluate_target_health = false
  }
}
