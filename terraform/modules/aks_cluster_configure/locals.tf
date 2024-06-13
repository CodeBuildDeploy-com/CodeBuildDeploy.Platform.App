locals {
  tags = {
    product      = var.product
    subscription = var.subscription_friendly_name
    platform_env = var.platform_env
    app_env      = var.app_env
  }
}