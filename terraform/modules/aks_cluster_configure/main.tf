resource "kubernetes_namespace" "cbd_app_namespace" {
  metadata {
    name = "cbd-${var.platform_env}-${var.app_env}"
  }
}

resource "kubernetes_secret" "cbd_app_kubernetes_pull_secret" {
  metadata {
    name      = "cbd-pull-secret"
    namespace = "cbd-${var.platform_env}-${var.app_env}"
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "${var.container_registry}" = {
          "username" = var.container_registry_username
          "password" = data.azurerm_key_vault_secret.cbd_global_acr_access_key.value
          "email"    = var.container_registry_email
          "auth"     = base64encode("${var.container_registry_username}:${data.azurerm_key_vault_secret.cbd_global_acr_access_key.value}")
        }
      }
    })
  }
}

#https://kubernetes.io/docs/concepts/configuration/secret
resource "kubernetes_secret" "cbd_app_secret_ssl_cert" {
  metadata {
    name      = "cbd-${var.app_env}-ssl-cert"
    namespace = "cbd-${var.platform_env}-${var.app_env}"
  }

  type = "kubernetes.io/tls"

  data = {
    "tls.crt" = data.azurerm_key_vault_secret.cbd_plat_tls_cert.value
    "tls.key" = data.azurerm_key_vault_secret.cbd_plat_tls_key.value
  }
}

resource "kubernetes_secret" "cbd_app_kubernetes_secret" {
  metadata {
    name      = "cbd-${var.app_env}-secret"
    namespace = "cbd-${var.platform_env}-${var.app_env}"
  }

  type = "Opaque"

  data = {
    "ConnectionStrings__BlogMigrationConnection" = "Server=tcp:cbd-${var.platform_env}-sql-server.database.windows.net,1433;Initial Catalog=cbd-${var.platform_env}-${var.app_env}-sql-database;Persist Security Info=False;User ID=cbd-sql-admin-${var.platform_env};Password='${sensitive(data.azurerm_key_vault_secret.cbd_plat_sql_server_admin_password.value)}';MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
    "ConnectionStrings__BlogConnection" = "Server=tcp:cbd-${var.platform_env}-sql-server.database.windows.net,1433;Initial Catalog=cbd-${var.platform_env}-${var.app_env}-sql-database;Persist Security Info=False;User ID=cbd-sql-admin-${var.platform_env};Password='${sensitive(data.azurerm_key_vault_secret.cbd_plat_sql_server_admin_password.value)}';MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
    "ConnectionStrings__AccountMigrationConnection" = "Server=tcp:cbd-${var.platform_env}-sql-server.database.windows.net,1433;Initial Catalog=cbd-${var.platform_env}-${var.app_env}-sql-database;Persist Security Info=False;User ID=cbd-sql-admin-${var.platform_env};Password='${sensitive(data.azurerm_key_vault_secret.cbd_plat_sql_server_admin_password.value)}';MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
    "ConnectionStrings__AccountConnection" = "Server=tcp:cbd-${var.platform_env}-sql-server.database.windows.net,1433;Initial Catalog=cbd-${var.platform_env}-${var.app_env}-sql-database;Persist Security Info=False;User ID=cbd-sql-admin-${var.platform_env};Password='${sensitive(data.azurerm_key_vault_secret.cbd_plat_sql_server_admin_password.value)}';MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
    "BlogsEndpointUrl" = "https://${var.app_env}.codebuilddeploy.co.uk"
  }
}