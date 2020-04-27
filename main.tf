provider "azurerm" {
  version = "~> 2.7.0"
  features {}
}

locals {
  aks_cluster_name = "testaksrice123"
}

resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "West Europe"
}

module "aks_private_link_dns_record" {
  source                     = "./modules/aks_private_link_dns_record"
  aks_cluster_name           = local.aks_cluster_name
  aks_cluster_resource_group = azurerm_resource_group.example.name
}

resource "azurerm_kubernetes_cluster" "example" {
  name                = local.aks_cluster_name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  dns_prefix          = "${local.aks_cluster_name}-dns"
  private_cluster_enabled = true

  network_profile {
    network_plugin = "kubenet"
    load_balancer_sku = "Standard"
  }

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Production"
  }
}

output "fqdn" {
  value = module.aks_private_link_dns_record.fqdn
}

output "zone" {
  value = module.aks_private_link_dns_record.zone
}

output "short_name" {
  value = module.aks_private_link_dns_record.short_name
}

output "ipv4_address" {
  value = module.aks_private_link_dns_record.ipv4_address
}

