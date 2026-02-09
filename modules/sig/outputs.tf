output "linux_imageID" {
  description = "linux share image defination"
  value       = azurerm_shared_image.linux.id
}

output "windows_imageID" {
  description = "linux share image defination"
  value       = azurerm_shared_image.windows.id
}
