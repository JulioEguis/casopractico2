# Cluster de Kubernetes gestionado (AKS) con un nodo worker para optimizar costos.
resource "azurerm_kubernetes_cluster" "aks" {
  name                              = var.aks_name
  location                          = azurerm_resource_group.rg.location
  resource_group_name               = azurerm_resource_group.rg.name
  dns_prefix                        = var.aks_dns_prefix
  sku_tier                          = var.aks_sku_tier
  role_based_access_control_enabled = true
  tags                              = local.common_tags

  default_node_pool {
    name       = "default"
    node_count = var.aks_node_count
    vm_size    = var.aks_vm_size
  }

  identity {
    type = "SystemAssigned"
  }
}

# Asignacion de rol AcrPull para permitir que AKS descargue imagenes del registry privado.
resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  depends_on = [
    azurerm_container_registry.acr,
    azurerm_kubernetes_cluster.aks
  ]
}