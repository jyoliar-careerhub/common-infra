locals {
  az_number = {
    a = 1
    b = 2
    c = 3
    d = 4
    e = 5
    f = 6
  }

  vpc_cidr_block = "10.0.0.0/16"
}

data "aws_availability_zones" "this" {
  state = "available"
}

data "aws_availability_zone" "this" {
  for_each = toset(slice(data.aws_availability_zones.this.names, 0, 3))

  name = each.key
}

module "vpc" {
  source = "../_modules/vpc"
  name   = "${var.env}-common-vpc"

  vpc_cidr_block = local.vpc_cidr_block
}
