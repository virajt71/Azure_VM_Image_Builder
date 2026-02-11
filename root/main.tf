module "template_rg" {
  source = "../modules/resource_group"

  name     = "${local.template_name}_rg"
  location = local.location

  tags = local.common_tags
}

module "linux_staging_rg" {
  source = "../modules/resource_group"

  name     = "linux_${local.staging_rg_name}_rg"
  location = local.location

  tags = local.common_tags
}

module "windows_staging_rg" {
  source = "../modules/resource_group"

  name     = "windows_${local.staging_rg_name}_rg"
  location = local.location

  tags = local.common_tags
}

resource "random_string" "this" {
  length  = 8
  special = false
  numeric = true
}

module "user_msi" {
  source = "../modules/managed_identity"

  location            = local.location
  resource_group_name = module.template_rg.name

  name                 = "aib_builder_User_id${random_string.this.result}"
  role_definition_name = "role_definition_${random_string.this.result}"

  assignable_scopes = module.template_rg.resource_group_id

  linux_scopes   = module.linux_staging_rg.resource_group_id
  windows_scopes = module.windows_staging_rg.resource_group_id

  tags = local.common_tags

  depends_on = [module.template_rg]
}

module "sig" {
  source = "../modules/sig"

  name                = "sig"
  location            = local.location
  resource_group_name = module.template_rg.name

  tags = local.common_tags

  depends_on = [module.template_rg]
}

# Linux Image Template
module "linux_image_template" {
  source = "../modules/image_template"

  name                      = "linux"
  parent_id                 = module.template_rg.resource_group_id
  location                  = local.location
  managed_identity_id       = module.user_msi.identity_ids
  staging_resource_group_id = module.linux_staging_rg.resource_group_id
  build_timeout_minutes     = 100

  image_source = {
    type      = "PlatformImage"
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  vm_profile = {
    vmSize       = "Standard_D2s_v3"
    osDiskSizeGB = 30
  }

  distribute = [
    {
      type           = "SharedImage"
      galleryImageId = module.sig.linux_imageID
      runOutputName  = "SharedImage_Output"
      artifactTags = {
        source    = "azureVmImageBuilder"
        baseosimg = "ubuntu2004"
      }
      targetRegions = [
        {
          name = local.location
        }
      ]
    }
  ]
  customize_steps = local.linux_customize_steps

  depends_on_resources = [module.user_msi]
}

module "linux_managed_image" {
  source = "../modules/image_template"

  name                      = "linux-managed"
  parent_id                 = module.template_rg.resource_group_id
  location                  = local.location
  managed_identity_id       = module.user_msi.identity_ids
  staging_resource_group_id = module.linux_staging_rg.resource_group_id
  build_timeout_minutes     = 100

  image_source = {
    type      = "PlatformImage"
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  vm_profile = {
    vmSize       = "Standard_D2s_v3"
    osDiskSizeGB = 30
  }

  distribute = [
    {
      type          = "ManagedImage"
      imageId       = "${module.template_rg.resource_group_id}/providers/Microsoft.Compute/images/linux-managed-image"
      location      = local.location
      runOutputName = "ManagedImage_Output"
      artifactTags = {
        source    = "azureVmImageBuilder"
        baseosimg = "ubuntu2004"
      }
    }
  ]
  customize_steps = local.linux_customize_steps

  depends_on_resources = [module.user_msi]
}

# Windows Image Template
module "windows_image_template" {
  source = "../modules/image_template"

  name                      = "windows"
  parent_id                 = module.template_rg.resource_group_id
  location                  = local.location
  managed_identity_id       = module.user_msi.identity_ids
  staging_resource_group_id = module.windows_staging_rg.resource_group_id
  build_timeout_minutes     = 100

  image_source = {
    type      = "PlatformImage"
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }

  vm_profile = {
    vmSize       = "Standard_D2s_v3"
    osDiskSizeGB = 127
  }

  distribute = [
    {
      type           = "SharedImage"
      galleryImageId = module.sig.windows_imageID
      runOutputName  = "Image_Output"
      artifactTags = {
        source    = "azureVmImageBuilder"
        baseosimg = "WindowsServer datacenter 2022"
      }
      targetRegions = [
        {
          name = local.location
        }
      ]
    }
  ]
  customize_steps = local.windows_customize_steps

  depends_on_resources = [module.user_msi]
}



# resource "terraform_data" "buildImage" {
#   triggers_replace = [timestamp()]

#   provisioner "local-exec" {
#     command = "az resource invoke-action --resource-group ${azurerm_resource_group.demo-rg.name} --resource-type Microsoft.VirtualMachineImages/imageTemplates -n ${azapi_resource.image-template.name} --action Run"
#   }

#   depends_on = [
#     azapi_resource.image-template
#   ]
# }
