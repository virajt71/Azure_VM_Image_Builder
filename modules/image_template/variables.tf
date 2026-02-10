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
  description = "Distribution configuration"
  type = list(object({
    type           = string
    galleryImageId = string
    runOutputName  = string
    artifactTags   = map(string)
    targetRegions = list(object({
      name = string
    }))
  }))
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