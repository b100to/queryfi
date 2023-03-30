#locals {
#  remote_states = {
#    "network"  = data.terraform_remote_state.this["network"].outputs
#    "security" = data.terraform_remote_state.this["security"].outputs
#  }
#  network  = local.remote_states["network"]
#  security = local.remote_states["security"]
#}

###################################################
# Terraform Remote States (External Dependencies)
###################################################

#data "terraform_remote_state" "this" {
#  for_each = local.config.remote_states
#
#  backend = "remote"
#
#  config = {
#    organization = each.value.organization
#    workspaces = {
#      name = "${each.value.workspace}-${local.config.env}"
#    }
#  }
#}
