data "azurerm_resource_group" "cbd_subscription_rg" {
  name = "cbd-${var.subscription_friendly_name}-rg"
}

data "azurerm_key_vault" "cbd_subscription_kv" {
  name                = "cbd-${var.subscription_friendly_name}-kv"
  resource_group_name = data.azurerm_resource_group.cbd_subscription_rg.name
}

data "azurerm_key_vault_secret" "cbd_global_acr_access_key" {
  name         = "cbd-global-acr-access-key"
  key_vault_id = data.azurerm_key_vault.cbd_subscription_kv.id
}

data "azurerm_key_vault_secret" "cbd_global_comm_services_connection_string" {
  name         = "cbd-global-comm-services-connection-string"
  key_vault_id = data.azurerm_key_vault.cbd_subscription_kv.id
}

data "azurerm_key_vault_secret" "cbd_app_jwt_private_key" {
  name         = "cbd-${var.platform_env}-${var.app_env}-jwt-private-key"
  key_vault_id = data.azurerm_key_vault.cbd_subscription_kv.id
}

data "azurerm_key_vault_secret" "cbd_app_google_client_id" {
  name         = "cbd-${var.platform_env}-${var.app_env}-google-client-id"
  key_vault_id = data.azurerm_key_vault.cbd_subscription_kv.id
}

data "azurerm_key_vault_secret" "cbd_app_google_client_secret" {
  name         = "cbd-${var.platform_env}-${var.app_env}-google-client-secret"
  key_vault_id = data.azurerm_key_vault.cbd_subscription_kv.id
}

data "azurerm_key_vault_secret" "cbd_app_microsoft_client_id" {
  name         = "cbd-${var.platform_env}-${var.app_env}-microsoft-client-id"
  key_vault_id = data.azurerm_key_vault.cbd_subscription_kv.id
}

data "azurerm_key_vault_secret" "cbd_app_microsoft_client_secret" {
  name         = "cbd-${var.platform_env}-${var.app_env}-microsoft-client-secret"
  key_vault_id = data.azurerm_key_vault.cbd_subscription_kv.id
}

data "azurerm_key_vault_secret" "cbd_plat_tls_cert" {
  name         = "cbd-${var.platform_env}-tls-cert"
  key_vault_id = data.azurerm_key_vault.cbd_subscription_kv.id
}

data "azurerm_key_vault_secret" "cbd_plat_tls_key" {
  name         = "cbd-${var.platform_env}-tls-key"
  key_vault_id = data.azurerm_key_vault.cbd_subscription_kv.id
}

data "azurerm_resource_group" "cbd_plat_rg" {
  name = "cbd-${var.platform_env}-rg"
}

data "azurerm_key_vault" "cbd_plat_kv" {
  name                = "cbd-${var.platform_env}-kv"
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

data "azurerm_resource_group" "cbd_app_rg" {
  name = "cbd-${var.platform_env}-${var.app_env}-rg"
}

data "azurerm_storage_account" "cbd_app_sa" {
  name                = "cbd${var.platform_env}${var.app_env}sa"
  resource_group_name = data.azurerm_resource_group.cbd_app_rg.name
}