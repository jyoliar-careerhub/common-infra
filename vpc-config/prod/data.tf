locals {
  core_subnets_ws = "${var.env}-core-subnets"
}

module "remote_state" {
  source = "../../_modules/tfc_remote_state"

  workspaces = [local.core_subnets_ws]
}

locals {
  core_subnets_outputs = module.remote_state.outputs[local.core_subnets_ws]
}
