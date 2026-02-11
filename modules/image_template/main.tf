locals {
  # Build distribute array with only the fields needed for each type
  distribute_list = [
    for dist in var.distribute : merge(
      {
        type          = dist.type
        runOutputName = dist.runOutputName
        artifactTags  = dist.artifactTags
      },
      dist.galleryImageId != null ? { galleryImageId = dist.galleryImageId } : {},
      dist.targetRegions != null ? { targetRegions = dist.targetRegions } : {},
      dist.imageId != null ? { imageId = dist.imageId } : {},
      dist.location != null && dist.type == "ManagedImage" ? { location = dist.location } : {},
      dist.uri != null ? { uri = dist.uri } : {}
    )
  ]
}

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
      distribute            = local.distribute_list
      customize             = var.customize_steps
    }
  }

  schema_validation_enabled = false

  depends_on = [var.depends_on_resources]
}
