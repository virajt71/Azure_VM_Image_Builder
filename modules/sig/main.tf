resource "azurerm_shared_image_gallery" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  description         = "Shared images and things."

  tags = var.tags
}

resource "azurerm_shared_image" "this" {
  name                = var.name
  gallery_name        = azurerm_shared_image_gallery.this.name
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
  hyper_v_generation  = "V2"

  identifier {
    publisher = "linux_aib_publisher"
    offer     = "linux_offer"
    sku       = "20_04-lts-gen2"
  }
}
