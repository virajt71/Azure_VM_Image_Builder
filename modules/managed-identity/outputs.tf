output "name" {
  description = "Mamagned Identity's name"
  value       = azurerm_user_assigned_identity.this.name
}

output "client_id_identity" {
  description = "Client's ID for mamagned identity"
  value       = azurerm_user_assigned_identity.this.client_id
}

output "identity_ids" {
  description = "identity URI"
  value       = azurerm_user_assigned_identity.this.id
}
