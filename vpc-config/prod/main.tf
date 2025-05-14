module "nat" {
  source = "../_modules/nat"

  name = "${var.env}-careerhub-nat"

  public_subnet_id = local.core_subnets_outputs.public_subnet_ids[0]
  route_table_id   = local.core_subnets_outputs.private_route_table_id
}

# 서버 인증서 가져오기
data "aws_acm_certificate" "server" {
  domain = "vpnserver.jyo-liar.com"
}

# 클라이언트 인증서 가져오기
data "aws_acm_certificate" "client" {
  domain = "vpnclient.jyo-liar.com"
}

data "aws_vpc" "this" {
  id = local.core_subnets_outputs.vpc_id
}

module "client_vpn" {
  source = "../_modules/client_vpn"

  # vpc cidr block과 겹치지 않도록 설정
  client_cidr_block      = "11.0.0.0/22"
  server_certificate_arn = data.aws_acm_certificate.server.arn
  client_certificate_arn = data.aws_acm_certificate.client.arn

  vpc_cidr_block = data.aws_vpc.this.cidr_block
}

resource "aws_ec2_client_vpn_network_association" "this" {
  for_each = toset(local.core_subnets_outputs.private_subnet_ids)

  client_vpn_endpoint_id = module.client_vpn.client_vpn_endpoint_id
  subnet_id              = each.value
}

# 라우팅 테이블 설정
# 추후 CIDR을 az별로 나누어 설정할 수 있도록 변경 필요
resource "aws_ec2_client_vpn_route" "this" {

  client_vpn_endpoint_id = module.client_vpn.client_vpn_endpoint_id
  destination_cidr_block = data.aws_vpc.this.cidr_block
  target_vpc_subnet_id   = local.core_subnets_outputs.private_subnet_ids[0]
}
