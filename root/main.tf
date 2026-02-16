# Template resource group
module "template_rg" {
  source = "../modules/resource_group"

  name     = "${local.template_name}_rg"
  location = local.location

  tags = local.common_tags
}

# Linux Staging Resource Group
module "linux_staging_rg" {
  source = "../modules/resource_group"

  name     = "linux_${local.staging_rg_name}_rg"
  location = module.template_rg.location

  tags = local.common_tags
}

# Windows Staging Resource Group
module "windows_staging_rg" {
  source = "../modules/resource_group"

  name     = "windows_${local.staging_rg_name}_rg"
  location = module.template_rg.location

  tags = local.common_tags
}

resource "random_string" "this" {
  length  = 8
  special = false
  numeric = true
}

# Create and Assign MSI to RG 
module "user_msi" {
  source = "../modules/managed_identity"

  location            = module.template_rg.location
  resource_group_name = module.template_rg.name

  name                 = "aib_builder_User_id${random_string.this.result}"
  role_definition_name = "role_definition_${random_string.this.result}"

  assignable_scopes = module.template_rg.resource_group_id

  linux_scopes   = module.linux_staging_rg.resource_group_id
  windows_scopes = module.windows_staging_rg.resource_group_id

  tags = local.common_tags

  depends_on = [module.template_rg]
}

# Create Shared Image Gallery
module "sig" {
  source = "../modules/sig"

  name                = "sig"
  location            = module.template_rg.location
  resource_group_name = module.template_rg.name

  tags = local.common_tags

  depends_on = [module.template_rg]
}

# Create Linux Image Definition
module "linux_image_definition" {
  source = "../modules/image_definition"

  name                = "linux_image_definition"
  sig_name            = module.sig.sig_name
  location            = module.template_rg.location
  resource_group_name = module.template_rg.name
  os_type             = "Linux"
  specialized         = false

  identifier = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
  }

  tags = local.common_tags
}

# Create Windows Image Definition
module "windows_image_definition" {
  source = "../modules/image_definition"

  name                = "windows_image_definition"
  sig_name            = module.sig.sig_name
  location            = module.template_rg.location
  resource_group_name = module.template_rg.name
  os_type             = "Windows"
  specialized         = false

  identifier = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
  }

  tags = local.common_tags
}

# Linux Image Template for Shared Image
module "linux_image_template" {
  source = "../modules/image_template"

  name                      = "linux"
  parent_id                 = module.template_rg.resource_group_id
  location                  = module.template_rg.location
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
      galleryImageId = module.linux_image_definition.image_definition_ID
      runOutputName  = "SharedImage_Output"
      artifactTags = {
        source    = "azureVmImageBuilder"
        baseosimg = "ubuntu2004"
      }
      targetRegions = [
        {
          name = module.template_rg.location
        }
      ]
    }
  ]
  customize_steps = local.linux_customize_steps

  depends_on_resources = [module.user_msi]
}

# Linux Image Template for Managed Image
module "linux_managed_image" {
  source = "../modules/image_template"

  name                      = "linux-managed"
  parent_id                 = module.template_rg.resource_group_id
  location                  = module.template_rg.location
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
      location      = module.template_rg.location
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

# Windows Image Template for Shared Image
module "windows_image_template" {
  source = "../modules/image_template"

  name                      = "windows"
  parent_id                 = module.template_rg.resource_group_id
  location                  = module.template_rg.location
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
      galleryImageId = module.windows_image_definition.image_definition_ID
      runOutputName  = "Image_Output"
      artifactTags = {
        source    = "azureVmImageBuilder"
        baseosimg = "WindowsServer datacenter 2022"
      }
      targetRegions = [
        {
          name = module.template_rg.location
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
