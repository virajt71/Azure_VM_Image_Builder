output "name" {
  description = "Resource group name"
  value       = azurerm_resource_group.this.name
}

output "location" {
  description = "Resource group location"
  value       = azurerm_resource_group.this.location
}

output "resource_group_id" {
  description = "Resource group ID for RBAC scoping"
  value       = azurerm_resource_group.this.id
}
