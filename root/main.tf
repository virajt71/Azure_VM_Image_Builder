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

resource "azapi_resource" "linux-template" {
  type      = "Microsoft.VirtualMachineImages/imageTemplates@2024-02-01"
  name      = "linux"
  parent_id = module.template_rg.resource_group_id
  location  = local.location
  body = {
    identity = {
      type = "UserAssigned"
      userAssignedIdentities = {
        (module.user_msi.identity_ids) = {}
      }
    }
    properties = {
      buildTimeoutInMinutes = 100
      stagingResourceGroup  = module.linux_staging_rg.resource_group_id
      source = {
        type      = "PlatformImage"
        publisher = "Canonical"
        offer     = "0001-com-ubuntu-server-focal"
        sku       = "20_04-lts-gen2"
        version   = "latest"
      }
      vmProfile = {
        vmSize       = "Standard_D2s_v3"
        osDiskSizeGB = 30
      }
      distribute = [
        {
          type           = "SharedImage"
          galleryImageId = module.sig.linux_imageID
          runOutputName  = "Image_Output"
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
      customize = [
        {
          type      = "Shell"
          name      = "RunScriptFromSource"
          scriptUri = "https://raw.githubusercontent.com/danielsollondon/azvmimagebuilder/master/quickquickstarts/customizeScript.sh"
        },
        {
          type           = "Shell"
          name           = "CheckSumCompareShellScript"
          scriptUri      = "https://raw.githubusercontent.com/danielsollondon/azvmimagebuilder/master/quickquickstarts/customizeScript2.sh"
          sha256Checksum = "ade4c5214c3c675e92c66e2d067a870c5b81b9844b3de3cc72c49ff36425fc93"
        },
        {
          type        = "File"
          name        = "downloadBuildArtifacts"
          sourceUri   = "https://raw.githubusercontent.com/danielsollondon/azvmimagebuilder/master/quickquickstarts/exampleArtifacts/buildArtifacts/index.html"
          destination = "/tmp/index.html"
        },
        {
          type = "Shell"
          name = "setupBuildPath"
          inline = [
            "sudo mkdir /buildArtifacts",
            "sudo cp /tmp/index.html /buildArtifacts/index.html"
          ]
        },
        {
          type = "Shell"
          name = "InstallUpgrades"
          inline = [
            "sudo apt-get update",
            "sudo apt-get install -y unattended-upgrades"
          ]
        }
      ]
    }
  }
  depends_on = [module.user_msi]
}

resource "azapi_resource" "windows-template" {
  type      = "Microsoft.VirtualMachineImages/imageTemplates@2024-02-01"
  name      = "windows"
  parent_id = module.template_rg.resource_group_id
  location  = local.location
  body = {
    identity = {
      type = "UserAssigned"
      userAssignedIdentities = {
        (module.user_msi.identity_ids) = {}
      }
    }
    properties = {
      buildTimeoutInMinutes = 100
      stagingResourceGroup  = module.windows_staging_rg.resource_group_id
      source = {
        type      = "PlatformImage"
        publisher = "MicrosoftWindowsServer"
        offer     = "WindowsServer"
        sku       = "2022-datacenter-azure-edition"
        version   = "latest"
      }
      vmProfile = {
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
      customize = [
        {
          type        = "PowerShell"
          name        = "CreateBuildPath"
          runElevated = false
          scriptUri   = "https://raw.githubusercontent.com/danielsollondon/azvmimagebuilder/master/testPsScript.ps1"
        },
        {
          type                = "WindowsRestart"
          restartCheckCommand = "echo Azure-Image-Builder-Restarted-the-VM  > c:\\buildArtifacts\\azureImageBuilderRestart.txt"
          restartTimeout      = "5m"
        },
        {
          type        = "File"
          name        = "downloadBuildArtifacts"
          sourceUri   = "https://raw.githubusercontent.com/danielsollondon/azvmimagebuilder/master/quickquickstarts/exampleArtifacts/buildArtifacts/index.html"
          destination = "c:\\buildArtifacts\\index.html"
        },
        {
          type        = "PowerShell"
          name        = "settingUpMgmtAgtPath"
          runElevated = false
          inline = [
            "mkdir c:\\buildActions",
            "echo Azure-Image-Builder-Was-Here  > c:\\buildActions\\buildActionsOutput.txt"
          ]
        }
      ]
    }
  }
  depends_on = [module.user_msi]
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
