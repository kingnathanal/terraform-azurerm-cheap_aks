resource "azurerm_kubernetes_cluster" "this" {
  name                      = var.aks_name
  location                  = var.location
  resource_group_name       = var.resource_group_name
  dns_prefix                = var.aks_dns_prefix
  node_resource_group       = "${var.resource_group_name}-managed"
  sku_tier                  = "Free"
  oidc_issuer_enabled       = true
  workload_identity_enabled = true


  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "basic"
  }

  default_node_pool {
    name           = "kubepool"
    node_count     = 1
    vm_size        = var.aks_sku
    vnet_subnet_id = var.vnet_subnet_id
    os_sku         = "Ubuntu"
  }

  dynamic "identity" {
    for_each = var.identity == null ? [] : ["enabled"]
    content {
      type = identity.value["type"]
      identity_ids = identity.value["identity_ids"]
    }
  }

  dynamic "identity" {
    for_each = var.identity != null ? [] : ["enabled"]
    content {
      type = "SystemAssigned"
    }
  }
}