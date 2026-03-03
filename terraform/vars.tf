
# Credenciales de Azure #
variable "subscription_id" {
  description = "ID de la suscripcion de Azure"
  type        = string
  sensitive   = true
}

variable "tenant_id" {
  description = "ID del tenant de Azure"
  type        = string
  sensitive   = true
}

variable "location" {
  description = "Region donde se desplegaran los recursos"
  type        = string
  default     = "francecentral"  # Tu región
}

variable "resource_group_name" {
  description = "Nombre del resource group principal"
  type        = string
  default     = "UNIR"  # Tu grupo de recursos
}

# Red y VM #
variable "vnet_name" {
  description = "Nombre de la red virtual"
  type        = string
  default     = "vnet-casopractico2"
}

variable "vnet_address_space" {
  description = "Rango CIDR principal de la red virtual"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_name" {
  description = "Nombre de la subred de la VM"
  type        = string
  default     = "snet-vm"
}

variable "subnet_address_prefixes" {
  description = "Rangos CIDR de la subred"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "nsg_name" {
  description = "Nombre del network security group"
  type        = string
  default     = "nsg-vm-casopractico2"
}

variable "public_ip_name" {
  description = "Nombre de la IP publica de la VM"
  type        = string
  default     = "pip-vm-casopractico2"
}

variable "nic_name" {
  description = "Nombre de la interfaz de red de la VM"
  type        = string
  default     = "nic-vm-casopractico2"
}

variable "vm_name" {
  description = "Nombre de la maquina virtual Linux"
  type        = string
  default     = "vm-casopractico2"
}

variable "vm_size" {
  description = "Tamano de la maquina virtual"
  type        = string
  default     = "Standard_B2ts_v2"  # tamaño de VM
}

variable "vm_admin_username" {
  description = "Usuario administrador de la VM"
  type        = string
  default     = "azureuser"
}


# ACR y AKS #
variable "acr_name" {
  description = "Nombre del Azure Container Registry"
  type        = string
  default     = "jevdevops"  # ACR 
}

variable "aks_name" {
  description = "Nombre del cluster AKS"
  type        = string
  default     = "aks-casopractico2"
}

variable "aks_dns_prefix" {
  description = "Prefijo DNS del cluster AKS"
  type        = string
  default     = "aks-casopractico2"
}

variable "aks_sku_tier" {
  description = "Tier del cluster AKS"
  type        = string
  default     = "Free"  # Free para ahorrar créditos
}

variable "aks_node_count" {
  description = "Numero de nodos del default node pool"
  type        = number
  default     = 1
}

variable "aks_vm_size" {
  description = "Tamano de VM de los nodos del cluster AKS"
  type        = string
  default     = "Standard_B2ts_v2"  # Tu tamaño
}