resource "azurerm_resource_group" "cbd_app_rg" {
  name     = "cbd-${var.platform_env}-${var.app_env}-rg"
  location = var.default_location
  tags     = local.tags
}

resource "azurerm_storage_account" "cbd_app_sa" {
  name                     = "cbd${var.platform_env}${var.app_env}sa"
  resource_group_name      = azurerm_resource_group.cbd_app_rg.name
  location                 = azurerm_resource_group.cbd_app_rg.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = local.tags
}

resource "azurerm_storage_container" "cbd_app_sc" {
  name                  = "cbd-${var.platform_env}-${var.app_env}-sc"
  storage_account_name  = azurerm_storage_account.cbd_app_sa.name
}

resource "azurerm_storage_blob" "cbd_app_sb" {
  name                   = "DataProtectionKey"
  storage_account_name   = azurerm_storage_account.cbd_app_sa.name
  storage_container_name = azurerm_storage_container.cbd_app_sc.name
  type                   = "Block"
}