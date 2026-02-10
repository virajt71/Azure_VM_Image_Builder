output "id" {
  description = "ID of the image template"
  value       = azapi_resource.image_template.id
}

output "name" {
  description = "Name of the image template"
  value       = azapi_resource.image_template.name
}

output "output" {
  description = "Full output of the image template resource"
  value       = azapi_resource.image_template.output
}