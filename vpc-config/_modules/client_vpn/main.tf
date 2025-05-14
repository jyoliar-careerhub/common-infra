resource "aws_ec2_client_vpn_endpoint" "this" {
  server_certificate_arn = var.server_certificate_arn
  # vpc cidr block과 겹치지 않도록 설정
  client_cidr_block = var.client_cidr_block
  dns_servers       = var.dns_servers

  # 상호 인증
  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = var.client_certificate_arn
  }

  # 연결 로깅
  connection_log_options {
    enabled = false
    # cloudwatch_log_group  = aws_cloudwatch_log_group.lg.name
    # cloudwatch_log_stream = aws_cloudwatch_log_stream.ls.name
  }
}

# 권한 부여 규칙 설정
resource "aws_ec2_client_vpn_authorization_rule" "vpc" { # VPC 내 리소스 접근
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.this.id
  target_network_cidr    = var.vpc_cidr_block
  authorize_all_groups   = true
}
