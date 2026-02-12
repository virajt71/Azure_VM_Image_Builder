resource "azurerm_shared_image" "this" {
  name                = var.name
  gallery_name        = var.sig_name
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = var.os_type
  specialized         = var.specialized
  hyper_v_generation  = var.hyper_v_generation

  identifier {
    publisher = var.identifier.publisher
    offer     = var.identifier.offer
    sku       = var.identifier.sku
  }

  tags = var.tags
}
