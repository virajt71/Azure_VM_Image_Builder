# Get subscription id
data "azurerm_subscription" "this" {}

# Create User Assigned Managed Identity
resource "azurerm_user_assigned_identity" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}

# Create custome role defination for image builder
resource "azurerm_role_definition" "this" {
  name        = var.role_definition_name
  scope       = data.azurerm_subscription.this.id
  description = "Image Builder access to create resources for the image build, you should delete or split out as appropriate"

  permissions {
    actions = [
      "Microsoft.Compute/galleries/read",
      "Microsoft.Compute/galleries/images/read",
      "Microsoft.Compute/galleries/images/versions/read",
      "Microsoft.Compute/galleries/images/versions/write",

      "Microsoft.Compute/images/write",
      "Microsoft.Compute/images/read",
      "Microsoft.Compute/images/delete",
    ]
    not_actions = []
  }

  # Assignable only at the specified resource group within the current subscription
  assignable_scopes = [
    var.assignable_scopes
  ]
}

resource "time_sleep" "this" {
  depends_on      = [azurerm_role_definition.this]
  create_duration = "120s"
}

resource "azurerm_role_assignment" "template_rg" {
  scope              = var.assignable_scopes
  role_definition_id = azurerm_role_definition.this.role_definition_resource_id
  principal_id       = azurerm_user_assigned_identity.this.principal_id

  depends_on = [time_sleep.this]
}

resource "azurerm_role_assignment" "linux_rg" {
  scope                = var.linux_scopes
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.this.principal_id

  depends_on = [time_sleep.this]
}

resource "azurerm_role_assignment" "windows_rg" {
  scope                = var.windows_scopes
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.this.principal_id

  depends_on = [time_sleep.this]
}
