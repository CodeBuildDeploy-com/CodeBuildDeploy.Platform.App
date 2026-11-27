locals {
  istio_gateway_chart = "${path.root}/../helm/istio-gateway"
  # CI uses a different address so it can run alongside Dev during cutover.
  istio_frontend_host = lookup({ ci = -9, dev = -8, live = -8 }, var.app_env, null)
}

data "azurerm_network_interface" "wireguard" {
  name                = "cbd-${var.platform_env}-wireguard-nic"
  resource_group_name = data.azurerm_resource_group.cbd_plat_rg.name
}

data "azurerm_subnet" "aks_ingress" {
  count = local.istio_frontend_host != null ? 1 : 0

  name                 = "cbd-${var.platform_env}-subnet-aks"
  resource_group_name  = data.azurerm_resource_group.cbd_plat_rg.name
  virtual_network_name = "cbd-${var.platform_env}-vnet"
}

resource "helm_release" "istio_gateway" {
  name      = "cbd-${var.app_env}-istio-gateway"
  namespace = kubernetes_namespace.cbd_app_namespace.metadata[0].name
  chart     = local.istio_gateway_chart
  version   = yamldecode(file("${local.istio_gateway_chart}/Chart.yaml")).version

  # Adopt the same-named release formerly deployed by ADO, or install it in a new namespace.
  upgrade_install = true
  atomic          = true
  reset_values    = true
  timeout         = 450

  values = [yamlencode({
    env                    = { name = var.app_env }
    privateFrontendAddress = local.istio_frontend_host != null ? cidrhost(one(data.azurerm_subnet.aks_ingress[0].address_prefixes), local.istio_frontend_host) : null
    wireguardSourceRange   = "${data.azurerm_network_interface.wireguard.private_ip_address}/32"
  })]

  depends_on = [kubernetes_secret.cbd_app_secret_ssl_cert]
}
