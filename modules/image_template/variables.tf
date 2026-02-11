variable "name" {
  description = "Name of the image template"
  type        = string
}

variable "parent_id" {
  description = "Parent resource group ID"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "managed_identity_id" {
  description = "ID of the user-assigned managed identity"
  type        = string
}

variable "build_timeout_minutes" {
  description = "Build timeout in minutes"
  type        = number
  default     = 100
}

variable "staging_resource_group_id" {
  description = "ID of the staging resource group"
  type        = string
}

variable "image_source" {
  description = "Source image configuration"
  type = object({
    type      = string
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
}

variable "vm_profile" {
  description = "VM profile configuration"
  type = object({
    vmSize       = string
    osDiskSizeGB = number
  })
}

variable "distribute" {
  description = "Distribution configuration - supports SharedImage, ManagedImage, and VHD types"
  type = list(object({
    type          = string
    runOutputName = string
    artifactTags  = map(string)
    # SharedImage specific (optional)
    galleryImageId = optional(string)
    targetRegions = optional(list(object({
      name               = string
      replicaCount       = optional(number)
      storageAccountType = optional(string)
    })))
    replication_regions = optional(list(string))
    # ManagedImage specific (optional)
    imageId  = optional(string)
    location = optional(string)
    # VHD specific (optional)
    uri = optional(string)
  }))

  validation {
    condition = alltrue([
      for dist in var.distribute : (
        (dist.type == "SharedImage" && dist.galleryImageId != null && dist.targetRegions != null) ||
        (dist.type == "ManagedImage" && dist.imageId != null && dist.location != null) ||
        (dist.type == "VHD" && dist.uri != null)
      )
    ])
    error_message = "Each distribution type requires specific fields: SharedImage (galleryImageId, targetRegions), ManagedImage (imageId, location), VHD (uri)"
  }
}

variable "customize_steps" {
  description = "Customization steps for the image"
  type        = any
}

variable "depends_on_resources" {
  description = "Resources this template depends on"
  type        = any
  default     = []
}
