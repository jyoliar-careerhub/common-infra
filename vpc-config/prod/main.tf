module "nat" {
  source = "../_modules/nat"

  name = "${var.env}-careerhub-nat"

  public_subnet_id = local.core_subnets_outputs.public_subnet_ids[0]
  route_table_id   = local.core_subnets_outputs.private_route_table_id
}
