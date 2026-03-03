terraform {
  required_version = ">= 1.6.0"
  required_providers {
    # Provider de Azure para crear y gestionar recursos en la nube.
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    # Provider TLS para generar el par de claves SSH de forma automatica.
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
  # Credenciales de Azure parametrizadas mediante variables de entorno.
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}