variable "name" {
  description = "identity names"
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

variable "role_defination_name" {
  description = "role defination name"
  type        = string
}

variable "assignable_scopes" {
  description = "assignable scopes"
  type        = string
}

variable "linux_scopes" {
  description = "linux rg scopes"
  type        = string
}

variable "windows_scopes" {
  description = "windows rg scopes"
  type        = string
}
variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}
