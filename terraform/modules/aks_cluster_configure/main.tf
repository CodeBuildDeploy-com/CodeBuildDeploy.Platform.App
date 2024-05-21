resource "kubernetes_namespace" "cbd_app_namespace" {
  metadata {
    name = "cbd-${var.platform_env}-${var.app_env}"
  }
}

resource "kubernetes_secret" "cbd_plat_kubernetes_pull_secret" {
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