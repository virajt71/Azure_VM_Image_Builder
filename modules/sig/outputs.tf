output "sig_name" {
  description = "linux share image defination"
  value       = azurerm_shared_image_gallery.sig.name
}

output "sig_ids" {
  description = "linux share image defination"
  value       = azurerm_shared_image_gallery.sig.id
}
