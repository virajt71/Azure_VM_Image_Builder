output "name" {
  description = "Managed Identity's name"
  value       = azurerm_user_assigned_identity.this.name
}

output "client_id_identity" {
  description = "Client's ID for Managed identity"
  value       = azurerm_user_assigned_identity.this.client_id
  sensitive   = true
}

output "identity_ids" {
  description = "identity URI"
  value       = azurerm_user_assigned_identity.this.id
}
