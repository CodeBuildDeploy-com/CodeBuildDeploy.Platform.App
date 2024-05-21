data "azurerm_resource_group" "cbd_global_rg" {
  name     = "cbd-global-rg"
}

data "azurerm_key_vault" "cbd_global_kv" {
  name                = "cbd-global-kv1"
  resource_group_name = data.azurerm_resource_group.cbd_global_rg.name
}

data "azurerm_key_vault_secret" "cbd_global_acr_access_key" {
  name         = "cbd-global-acr-access-key"
  key_vault_id = data.azurerm_key_vault.cbd_global_kv.id
}

data "azurerm_resource_group" "cbd_plat_rg" {
  name     = "cbd-${var.platform_env}-rg"
}

data "azurerm_key_vault" "cbd_plat_kv" {
  name                = "cbd-${var.platform_env}-kv1"
  resource_group_name = data.azurerm_resource_group.cbd_plat_rg.name
}

data "azurerm_key_vault_secret" "cbd_plat_sql_server_admin_password" {
  name         = "cbd-${var.platform_env}-sql-server-admin-password"
  key_vault_id = data.azurerm_key_vault.cbd_plat_kv.id
}

data "azurerm_kubernetes_cluster" "cbd_plat_aks_cluster" {
  name                = "cbd-${var.platform_env}-aks-cluster"
  resource_group_name = data.azurerm_resource_group.cbd_plat_rg.name
}