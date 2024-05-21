data "azurerm_resource_group" "cbd_plat_rg" {
  name     = "cbd-${var.platform_env}-rg"
}

data "azurerm_kubernetes_cluster" "cbd_plat_aks_cluster" {
  name                = "cbd-${var.platform_env}-aks-cluster"
  resource_group_name = data.azurerm_resource_group.cbd_plat_rg.name
}