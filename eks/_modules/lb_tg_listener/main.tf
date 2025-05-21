resource "aws_lb_target_group" "this" {
  name        = "${var.name}-tg"
  vpc_id      = var.vpc_id
  target_type = "ip"
  protocol    = var.target_protocol
  port        = var.target_port

  health_check {
    path = var.health_check_path
  }

  tags = merge(
    {
      Name = "${var.name}-tg"
    },
    var.target_group_tags
  )
}

resource "aws_lb_listener" "this" {

  load_balancer_arn = var.load_balancer_arn
  port              = var.port
  protocol          = var.protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

resource "aws_security_group_rule" "this" {
  type              = "ingress"
  from_port         = var.port
  to_port           = var.port
  protocol          = var.sg_protocol
  security_group_id = var.lb_sg_id
  cidr_blocks       = var.access_allow_cidr_blocks
}
