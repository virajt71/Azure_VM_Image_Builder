resource "azapi_resource" "image_template" {
  type      = "Microsoft.VirtualMachineImages/imageTemplates@2024-02-01"
  name      = var.name
  parent_id = var.parent_id
  location  = var.location

  body = {
    identity = {
      type = "UserAssigned"
      userAssignedIdentities = {
        (var.managed_identity_id) = {}
      }
    }
    properties = {
      buildTimeoutInMinutes = var.build_timeout_minutes
      stagingResourceGroup  = var.staging_resource_group_id
      source                = var.image_source
      vmProfile             = var.vm_profile
      distribute            = var.distribute
      customize             = var.customize_steps
    }
  }

  depends_on = [var.depends_on_resources]
}