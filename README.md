# Azure Image Builder Terraform Module

This repository contains Terraform modules for creating and managing Azure VM images using Azure Image Builder. It supports both Linux (Ubuntu) and Windows Server image creation with customization steps, and can distribute images to Shared Image Galleries, Managed Images, or VHDs.

## Overview

Azure Image Builder is a service that helps you create custom VM images with pre-installed applications and configurations. This Terraform implementation automates the infrastructure setup and image template creation process.

## Features

- **Multi-OS Support**: Create both Linux (Ubuntu 20.04) and Windows Server 2022 images
- **Flexible Distribution**: Support for Shared Image Gallery, Managed Images, and VHD distributions
- **Customization Pipeline**: Execute shell scripts, PowerShell scripts, file transfers, and Windows restarts
- **Modular Design**: Reusable Terraform modules for different components
- **RBAC Management**: Automated managed identity and role assignment setup
- **Staging Resource Groups**: Separate staging environments for Linux and Windows builds

## Architecture

The solution creates the following resources:

```
├── Template Resource Group
│   ├── Shared Image Gallery (SIG)
│   │   ├── Linux Image Definition
│   │   └── Windows Image Definition
│   ├── User-Assigned Managed Identity
│   ├── Custom Role Definition
│   └── Image Templates (Linux & Windows)
├── Linux Staging Resource Group
└── Windows Staging Resource Group
```

## Module Structure

```
.
├── modules/
│   ├── image_template/    # Image template creation
│   ├── managed_identity/  # MSI and RBAC setup
│   ├── resource_group/    # Resource group module
│   └── sig/              # Shared Image Gallery
└── root/                 # Root configuration
    ├── main.tf
    ├── locals.tf
    ├── providers.tf
    └── outputs.tf
```

## Quick Start

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd <repository-name>
   ```

2. **Navigate to the root directory**
   ```bash
   cd root
   ```

3. **Initialize Terraform**
   ```bash
   terraform init
   ```

4. **Review the plan**
   ```bash
   terraform plan
   ```

5. **Apply the configuration**
   ```bash
   terraform apply
   ```

6. **Trigger image build** (after infrastructure is created)
   ```bash
   az resource invoke-action \
     --resource-group template_rg \
     --resource-type Microsoft.VirtualMachineImages/imageTemplates \
     --name linux \
     --action Run
   ```

## Configuration

### Customizing Image Sources

Edit `root/main.tf` to modify the base images:

```hcl
image_source = {
  type      = "PlatformImage"
  publisher = "Canonical"
  offer     = "0001-com-ubuntu-server-focal"
  sku       = "20_04-lts-gen2"
  version   = "latest"
}
```

### Customizing Build Steps

Modify `root/locals.tf` to add or change customization steps:

**Linux Example:**
```hcl
linux_customize_steps = [
  {
    type   = "Shell"
    name   = "InstallNginx"
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y nginx"
    ]
  }
]
```

**Windows Example:**
```hcl
windows_customize_steps = [
  {
    type        = "PowerShell"
    name        = "InstallIIS"
    runElevated = true
    inline      = [
      "Install-WindowsFeature -Name Web-Server -IncludeManagementTools"
    ]
  }
]
```

### Distribution Options

The module supports three distribution types:

**1. Shared Image Gallery**
```hcl
distribute = [
  {
    type           = "SharedImage"
    galleryImageId = module.sig.linux_imageID
    runOutputName  = "SharedImage_Output"
    artifactTags   = { source = "azureVmImageBuilder" }
    targetRegions  = [
      {
        name               = "northeurope"
        replicaCount       = 1
        storageAccountType = "Standard_LRS"
      }
    ]
  }
]
```

**2. Managed Image**
```hcl
distribute = [
  {
    type          = "ManagedImage"
    imageId       = "${module.template_rg.resource_group_id}/providers/Microsoft.Compute/images/my-image"
    location      = "northeurope"
    runOutputName = "ManagedImage_Output"
    artifactTags  = { source = "azureVmImageBuilder" }
  }
]
```

**3. VHD**
```hcl
distribute = [
  {
    type          = "VHD"
    uri           = "https://mystorageaccount.blob.core.windows.net/vhds/myimage.vhd"
    runOutputName = "VHD_Output"
    artifactTags  = { source = "azureVmImageBuilder" }
  }
]
```

## Modules

### image_template

Creates Azure Image Builder templates with customization and distribution configuration.

**Inputs:**
- `name` - Template name
- `parent_id` - Resource group ID
- `location` - Azure region
- `managed_identity_id` - User-assigned managed identity ID
- `staging_resource_group_id` - Staging RG for build process
- `image_source` - Source image configuration
- `vm_profile` - VM size and disk configuration
- `distribute` - Distribution targets
- `customize_steps` - Customization pipeline

### managed_identity

Creates a user-assigned managed identity with custom role definition and assignments.

**Inputs:**
- `name` - Identity name
- `location` - Azure region
- `resource_group_name` - Resource group name
- `role_definition_name` - Custom role name
- `assignable_scopes` - Scope for role assignment
- `linux_scopes` - Linux staging RG scope
- `windows_scopes` - Windows staging RG scope

### resource_group

Creates Azure resource groups with validation.

**Inputs:**
- `name` - Resource group name
- `location` - Azure region (northeurope, westeurope, uksouth, ukwest)
- `tags` - Resource tags

### sig

Creates a Shared Image Gallery with Linux and Windows image definitions.

**Inputs:**
- `name` - Gallery name
- `location` - Azure region
- `resource_group_name` - Resource group name
- `tags` - Resource tags

## Outputs

- `template_rg_id` - Template resource group ID
- `client_id_identity` - Managed identity client ID (sensitive)
- `identity_ids` - Managed identity resource ID

## Security

- Secrets scanning with Gitleaks (GitHub Actions + pre-commit hooks)
- Managed identity for Azure authentication
- Least privilege RBAC with custom role definitions
- No hardcoded credentials in code

### Pre-commit Hooks

Install pre-commit hooks to scan for secrets before committing:

```bash
pip install pre-commit
pre-commit install
```

## Image Build Process

The image build follows these steps:

1. **Provision**: Azure Image Builder creates a temporary VM in the staging resource group
2. **Customize**: Executes customization steps in order
3. **Generalize**: Syspreps/deprovisions the VM
4. **Distribute**: Copies the image to specified distribution targets
5. **Cleanup**: Removes temporary resources

## Build Timeout

Default build timeout is 100 minutes. Adjust in `root/main.tf`:

```hcl
build_timeout_minutes = 100
```

## Limitations

- Image Builder service must be available in your Azure region
- Maximum build timeout is 960 minutes (16 hours)
- Staging resource groups are created but not automatically deleted after builds
- Custom role permissions are broad - consider restricting for production

## Troubleshooting

### Build Failures

Check the build logs:
```bash
az resource show \
  --ids "/subscriptions/<subscription-id>/resourceGroups/template_rg/providers/Microsoft.VirtualMachineImages/imageTemplates/linux" \
  --query "properties.lastRunStatus"
```

### Permission Issues

Ensure the managed identity has:
- Contributor access to staging resource groups
- Custom role access to template resource group
- Wait time (120s) is included for role propagation

### Common Errors

- **"The resource is not found"**: Wait for role assignments to propagate
- **"Build timed out"**: Increase `build_timeout_minutes`
- **"Failed to run customization step"**: Check script URLs and syntax

## Cost Considerations

- VM compute costs during image build (typically 30-60 minutes)
- Storage costs for Shared Image Gallery replicas
- Storage costs for Managed Images or VHDs
- No cost for Image Builder service itself

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run pre-commit hooks
5. Submit a pull request

## License

MIT License - see [LICENSE](LICENSE) file for details

## References

- [Azure Image Builder Documentation](https://docs.microsoft.com/azure/virtual-machines/image-builder-overview)
- [Azure Image Builder Terraform Provider](https://registry.terraform.io/providers/Azure/azapi/latest/docs)
- [Image Builder Quickstarts](https://github.com/danielsollondon/azvmimagebuilder)

## Support

For issues and questions:
- Open an issue in this repository
- Consult Azure Image Builder documentation
- Review Azure support resources

---

**Note**: This is a demonstration/development setup. For production use, consider:
- Implementing state backend (Azure Storage)
- Adding encryption at rest
- Restricting role permissions
- Implementing approval workflows for image builds
- Adding automated testing
- Setting up monitoring and alerting
