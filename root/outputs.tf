output "template_rg_id" {
  value = module.template_rg.resource_group_id
}

output "client_id_identity" {
  description = "Client's ID for Managed identity"
  value       = module.user_msi.client_id_identity
  sensitive   = true
}

output "identity_ids" {
  description = "identity URI"
  value       = module.user_msi.identity_ids
}
