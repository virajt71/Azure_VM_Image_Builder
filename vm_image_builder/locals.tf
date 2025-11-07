locals {
  env         = "test"
  location    = "northeurope"
  name_prefix = "app-${local.env}"

  common_tags = {
    environment = local.env
    managed_by  = "terraform"
  }
}

variable "subscription" {
  type = string
}

