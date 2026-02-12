variable "name" {
  description = "Prefix for resource names"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "sig_name" {
  description = "Shared image gallary name"
  type        = string
}

variable "os_type" {
  description = "os type"
  type        = string

  validation {
    condition     = contains(["Linux", "Windows"], var.os_type)
    error_message = "Location must be a valid Azure region."
  }
}

variable "specialized" {
  description = "set to true for specialized, false is for generalization"
  type        = bool
}

variable "hyper_v_generation" {
  description = "hyper-v generation"
  type        = string
  default     = "V2"
  validation {
    condition     = contains(["V1", "V2"], var.hyper_v_generation)
    error_message = "Must be set to V1 or V2"
  }
}

variable "identifier" {
  description = "OS identifier"
  type = object({
    publisher = string
    offer     = string
    sku       = string
  })
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}
