resource "azurerm_shared_image_gallery" "sig" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  description         = "Shared images and things."

  tags = var.tags
}

