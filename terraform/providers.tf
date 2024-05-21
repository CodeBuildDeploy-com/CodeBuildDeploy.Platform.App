terraform {
  required_version = ">= 1.8.2"

  required_providers {
    #https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.101.0"
    }
    #https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~>2.30.0"
    }
    #https://registry.terraform.io/providers/hashicorp/helm/latest/docs
    helm = {
      source  = "hashicorp/helm"
      version = "~>2.13.2"
    }
  }

  backend "azurerm" { }
}

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "cbd_plat_rg" {
  name     = "cbd-${var.platform_env}-rg"
}

data "azurerm_kubernetes_cluster" "cbd_plat_aks_cluster" {
  name                = "cbd-${var.platform_env}-aks-cluster"
  resource_group_name = data.azurerm_resource_group.cbd_plat_rg.name
}

data "azurerm_user_assigned_identity" "cbd_plat_aks_identity" {
  name                = "cbd-${var.platform_env}-aks-identity"
  resource_group_name = data.azurerm_resource_group.cbd_plat_rg.name
}

provider "kubernetes" {
  host                   = data.azurerm_kubernetes_cluster.cbd_plat_aks_cluster.kube_config.0.host
  #username               = data.azurerm_kubernetes_cluster.cbd_plat_aks_cluster.kube_config[0].username
  #password               = data.azurerm_kubernetes_cluster.cbd_plat_aks_cluster.kube_config[0].password
  #client_certificate     = base64decode(data.azurerm_kubernetes_cluster.cbd_plat_aks_cluster.kube_config.0.client_certificate)
  #client_key             = base64decode(data.azurerm_kubernetes_cluster.cbd_plat_aks_cluster.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.cbd_plat_aks_cluster.kube_config.0.cluster_ca_certificate)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "kubelogin"
    args = [
      "get-token",
      "--login",
      "azurecli",
      #"spn",
      #"--environment",
      #"AzurePublicCloud",
      #"--tenant-id",
      #data.azurerm_client_config.current.tenant_id,
      "--server-id",
      "6dae42f8-4368-4678-94ff-3960e28e3630",
      #yamldecode(data.azurerm_kubernetes_cluster.cbd_plat_aks_cluster.kube_config_raw)["users"][0]["user"]["exec"]["args"][4],
      #"--client-id",
      #data.azurerm_client_config.current.client_id,
      #"--client-secret",
      #"FROM_VAULT",
    ]
  }
}

provider "helm" {
  kubernetes {
    host                   = data.azurerm_kubernetes_cluster.cbd_plat_aks_cluster.kube_config.0.host
    #username               = data.azurerm_kubernetes_cluster.cbd_plat_aks_cluster.kube_config[0].username
    #password               = data.azurerm_kubernetes_cluster.cbd_plat_aks_cluster.kube_config[0].password
    #client_certificate     = base64decode(data.azurerm_kubernetes_cluster.cbd_plat_aks_cluster.kube_config.0.client_certificate)
    #client_key             = base64decode(data.azurerm_kubernetes_cluster.cbd_plat_aks_cluster.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.cbd_plat_aks_cluster.kube_config.0.cluster_ca_certificate)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "kubelogin"
      args = [
        "get-token",
        "--login",
        "azurecli",
        "--server-id",
        "6dae42f8-4368-4678-94ff-3960e28e3630",
      ]
    }
  }
}