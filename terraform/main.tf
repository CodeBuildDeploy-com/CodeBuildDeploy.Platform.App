module "cbd_app_core_resources" {
  source = "./modules/core_resources"

  subscription_short_name = var.subscription_short_name
  platform_env            = var.platform_env
  app_env                 = var.app_env
}

module "cbd_app_sql_database" {
  source = "./modules/sql_database"
 
  subscription_short_name = var.subscription_short_name
  platform_env            = var.platform_env
  app_env                 = var.app_env
}

module "cbd_app_aks_cluster_configure" {
  source = "./modules/aks_cluster_configure"
 
  subscription_short_name     = var.subscription_short_name
  platform_env                = var.platform_env
  app_env                     = var.app_env
  container_registry          = var.container_registry
  container_registry_username = var.container_registry_username
}