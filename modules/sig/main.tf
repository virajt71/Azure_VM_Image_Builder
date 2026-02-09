resource "azurerm_shared_image_gallery" "sig" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  description         = "Shared images and things."

  tags = var.tags
}

resource "azurerm_shared_image" "linux" {
  name                = "${var.name}_linux"
  gallery_name        = azurerm_shared_image_gallery.sig.name
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
  specialized         = true
  hyper_v_generation  = "V2"

  identifier {
    publisher = "linux_aib_publisher"
    offer     = "linux_offer"
    sku       = "20_04-lts-gen2"
  }
}

resource "azurerm_shared_image" "windows" {
  name                = "${var.name}_windows"
  gallery_name        = azurerm_shared_image_gallery.sig.name
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Windows"
  specialized         = true
  hyper_v_generation  = "V2"

  identifier {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
  }
}
