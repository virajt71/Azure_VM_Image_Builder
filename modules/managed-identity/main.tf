#Create User Assigned Managed Identity
resource "azurerm_user_assigned_identity" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}

resource "azurerm_role_assignment" "this" {
  scope                = var.scope
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.this.client_id
}
