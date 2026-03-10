# IP pública de la VM
output "vm_public_ip" {
  description = "IP publica de la maquina virtual"
  value       = azurerm_public_ip.vm_public_ip.ip_address
}

# Clave SSH privada
output "ssh_private_key" {
  description = "Clave SSH privada para acceder a la VM"
  value       = tls_private_key.ssh_key.private_key_openssh
  sensitive   = true
}

# Credenciales del ACR
output "acr_login_server" {
  description = "URL del Azure Container Registry"
  value       = azurerm_container_registry.acr.login_server
}

output "acr_admin_username" {
  description = "Usuario admin del ACR"
  value       = azurerm_container_registry.acr.admin_username
}

output "acr_admin_password" {
  description = "Password admin del ACR"
  value       = azurerm_container_registry.acr.admin_password
  sensitive   = true
}
