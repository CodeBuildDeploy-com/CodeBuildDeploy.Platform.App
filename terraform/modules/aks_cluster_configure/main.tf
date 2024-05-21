resource "kubernetes_namespace" "cbd_app_namespace" {
  metadata {
    name = "cbd-${var.platform_env}-${var.app_env}"
  }
}