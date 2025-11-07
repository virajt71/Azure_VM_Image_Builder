module "resource_group" {
  source = "../modules/resource-group"

  name = "${local.name_prefix}-rg"

  location = local.location
  tags     = local.common_tags
}

module "resource_group_linux" {
  source = "../modules/resource-group"

  name = "${local.name_prefix}-linux-rg"

  location = local.location
  tags     = local.common_tags
}

module "identity" {
  source = "../modules/managed-identity"

  name                = "${local.name_prefix}-identity"
  location            = local.location
  resource_group_name = module.resource_group.name

  scope = module.resource_group_linux.resource_group_id

  tags = local.common_tags
}

module "sig" {
  source = "../modules/sig"

  name                = "${local.name_prefix}-sig"
  location            = local.location
  resource_group_name = module.resource_group_linux

  tags = local.common_tags
}

