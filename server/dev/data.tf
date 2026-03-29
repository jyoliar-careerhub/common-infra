locals {
  eks_subnets_ws = "${var.env}-eks-subnets"
}

module "remote_state" {
  source = "../../_modules/tfc_remote_state"

  workspaces = [local.eks_subnets_ws]
}

locals {
  eks_subnets_outputs = module.remote_state.outputs[local.eks_subnets_ws]
}
