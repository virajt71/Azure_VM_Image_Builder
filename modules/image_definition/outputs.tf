output "image_definition_name" {
  description = "linux share image defination"
  value       = azurerm_shared_image.this.name
}

output "image_definition_ID" {
  description = "linux share image defination"
  value       = azurerm_shared_image.this.id
}
