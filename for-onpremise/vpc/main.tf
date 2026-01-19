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

  core_cidr_block = cidrsubnet(local.vpc_cidr_block, 4, 0)
  eks_cidr_block  = cidrsubnet(local.vpc_cidr_block, 4, 1)
}

data "aws_availability_zones" "this" {
  state = "available"
}

data "aws_availability_zone" "this" {
  for_each = toset(slice(data.aws_availability_zones.this.names, 0, 3))

  name = each.key
}

# VPC
module "vpc" {
  source = "../_modules/vpc"
  name   = "${var.env}-common-vpc"

  vpc_cidr_block = local.vpc_cidr_block
}

# Core Subnets
module "core_subnets" {
  source = "../_modules/subnets"
  name   = "${var.env}-core"

  vpc_id                 = module.vpc.vpc_id
  public_route_table_id  = module.vpc.public_route_table_id
  private_route_table_id = module.vpc.private_route_table_id

  public_subnets = [
    for az_name, az_zone in data.aws_availability_zone.this : {
      cidr_block        = cidrsubnet(local.core_cidr_block, 4, local.az_number[az_zone.name_suffix])
      availability_zone = az_name
    }
  ]

  private_subnets = [
    for az_name, az_zone in data.aws_availability_zone.this : {
      cidr_block        = cidrsubnet(local.core_cidr_block, 4, local.az_number[az_zone.name_suffix] + 8)
      availability_zone = az_name
    }
  ]
}

# EKS Subnets
module "eks_subnets" {
  source = "../_modules/subnets"
  name   = "${var.env}-eks"

  vpc_id                 = module.vpc.vpc_id
  public_route_table_id  = module.vpc.public_route_table_id
  private_route_table_id = module.vpc.private_route_table_id

  public_subnets = [
    for az_name, az_zone in data.aws_availability_zone.this : {
      cidr_block        = cidrsubnet(local.eks_cidr_block, 4, local.az_number[az_zone.name_suffix])
      availability_zone = az_name
    }
  ]

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  private_subnets = [
    for az_name, az_zone in data.aws_availability_zone.this : {
      cidr_block        = cidrsubnet(local.eks_cidr_block, 4, local.az_number[az_zone.name_suffix] + 8)
      availability_zone = az_name
    }
  ]
}
