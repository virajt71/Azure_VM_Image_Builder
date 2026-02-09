variable "name" {
  description = "Resource group name"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9-_]+$", var.name))
    error_message = "Resource group name can only contain alphanumeric characters, hyphens, and underscores."
  }
}

variable "location" {
  description = "Azure region"
  type        = string

  validation {
    condition = contains([
      "northeurope", "westeurope", "uksouth", "ukwest"
    ], var.location)
    error_message = "Location must be a valid Azure region."
  }
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}
