locals {
  az_number = {
    a = 1
    b = 2
    c = 3
    d = 4
    e = 5
    f = 6
  }

  total_cidr_block = cidrsubnet(local.vpc_outputs.vpc_cidr_block, 4, 1)
}

data "aws_availability_zones" "this" {
  state = "available"
}

data "aws_availability_zone" "this" {
  for_each = toset(slice(data.aws_availability_zones.this.names, 0, 3))

  name = each.key
}

module "subnets" {
  source = "../../_modules/subnets"
  name   = "${var.env}-eks"

  vpc_id                 = local.vpc_outputs.vpc_id
  public_route_table_id  = local.vpc_outputs.public_route_table_id
  private_route_table_id = local.vpc_outputs.private_route_table_id

  public_subnets = [
    for az_name, az_zone in data.aws_availability_zone.this : {
      cidr_block        = cidrsubnet(local.total_cidr_block, 4, local.az_number[az_zone.name_suffix])
      availability_zone = az_name
    }
  ]


  private_subnets = [
    for az_name, az_zone in data.aws_availability_zone.this : {
      cidr_block        = cidrsubnet(local.total_cidr_block, 4, local.az_number[az_zone.name_suffix] + 8)
      availability_zone = az_name
    }
  ]
}
