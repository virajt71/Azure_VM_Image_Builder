output "client_id_identity" {
  description = "Client's ID for mamagned identity"
  value       = module.identity.client_id_identity
}

output "identity ids" {
  description = "identity URI"
  value       = module.identity.identity_ids
}
