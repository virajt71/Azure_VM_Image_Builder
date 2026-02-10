locals {
  template_name   = "template"
  staging_rg_name = "staging"
  location        = "northeurope"

  common_tags = {
    managed_by = "terraform"
  }

  # Linux customization steps
  linux_customize_steps = [
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

  # Windows customization steps
  windows_customize_steps = [
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