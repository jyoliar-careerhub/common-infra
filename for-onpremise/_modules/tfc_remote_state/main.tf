data "tfe_organizations" "this" {
  lifecycle {
    postcondition {
      condition     = length(self.names) == 1
      error_message = "Only one organization is allowed"
    }
  }
}

data "tfe_outputs" "this" {
  for_each = toset(var.workspaces)

  organization = data.tfe_organizations.this.names[0]
  workspace    = each.value
}
