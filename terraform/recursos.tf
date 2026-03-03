locals {
 # Tags aplicados a todos los recursos del proyecto.
  common_tags = {
    environment = "casopractico2"
  }
}

# Grupo de recursos principal que contiene toda la infraestructura del caso practico.
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = local.common_tags
}