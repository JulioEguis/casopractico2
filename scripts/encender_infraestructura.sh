#!/bin/bash

# Script para encender infraestructura de Azure - Caso Práctico 2
# Autor: Julio Eguis Vásquez
# Fecha: Marzo 2026

set -e  # Detener si hay errores

echo "=========================================="
echo "  ENCENDIDO INFRAESTRUCTURA AZURE CP2"
echo "=========================================="
echo ""

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # Sin color

RESOURCE_GROUP="UNIR-casopractico2"
AKS_NAME="aks-casopractico2"
VM_NAME="vm-casopractico2"
NAMESPACE="casopractico2"

# Función para verificar estado de AKS
check_aks_state() {
    echo -e "${YELLOW}Verificando estado del AKS...${NC}"
    POWER_STATE=$(az aks show --resource-group $RESOURCE_GROUP --name $AKS_NAME --query "powerState.code" -o tsv 2>/dev/null)
    echo "Estado actual: $POWER_STATE"
}

# Función para verificar estado de VM
check_vm_state() {
    echo -e "${YELLOW}Verificando estado de la VM...${NC}"
    VM_STATE=$(az vm show --resource-group $RESOURCE_GROUP --name $VM_NAME --query "powerState" -o tsv 2>/dev/null)
    echo "Estado actual: $VM_STATE"
}

# PASO 1: Encender AKS
echo -e "${YELLOW}[1/4] Encendiendo cluster AKS...${NC}"
check_aks_state

if [[ "$POWER_STATE" == "Stopped" ]]; then
    echo "Iniciando AKS (esto tarda 2-3 minutos)..."
    az aks start --resource-group $RESOURCE_GROUP --name $AKS_NAME
    echo -e "${GREEN}✓ AKS iniciado correctamente${NC}"
else
    echo -e "${GREEN}✓ AKS ya está en ejecución${NC}"
fi

# Esperar a que AKS esté completamente disponible
echo ""
echo -e "${YELLOW}Esperando a que AKS esté completamente operativo...${NC}"
MAX_ATTEMPTS=30
ATTEMPT=1

while [ $ATTEMPT -le $MAX_ATTEMPTS ]; do
    sleep 10
    POWER_STATE=$(az aks show --resource-group $RESOURCE_GROUP --name $AKS_NAME --query "powerState.code" -o tsv 2>/dev/null)
    
    echo -n "."
    
    if [[ "$POWER_STATE" == "Running" ]]; then
        echo ""
        echo -e "${GREEN}✓ AKS completamente operativo${NC}"
        break
    fi
    
    ATTEMPT=$((ATTEMPT + 1))
    
    if [ $ATTEMPT -gt $MAX_ATTEMPTS ]; then
        echo ""
        echo -e "${RED}⚠ Timeout esperando a que AKS inicie${NC}"
        exit 1
    fi
done

# PASO 2: Encender VM
echo ""
echo -e "${YELLOW}[2/4] Encendiendo máquina virtual...${NC}"
check_vm_state

if [[ "$VM_STATE" == *"deallocated"* ]] || [[ "$VM_STATE" == *"stopped"* ]]; then
    echo "Iniciando VM (esto tarda 30-60 segundos)..."
    az vm start --resource-group $RESOURCE_GROUP --name $VM_NAME
    echo -e "${GREEN}✓ VM iniciada correctamente${NC}"
else
    echo -e "${GREEN}✓ VM ya está en ejecución${NC}"
fi

# PASO 3: Obtener credenciales de AKS
echo ""
echo -e "${YELLOW}[3/4] Configurando acceso a AKS...${NC}"
az aks get-credentials --resource-group $RESOURCE_GROUP --name $AKS_NAME --overwrite-existing
echo -e "${GREEN}✓ Credenciales de AKS obtenidas${NC}"

# PASO 4: Verificar que todo está funcionando
echo ""
echo -e "${YELLOW}[4/4] Verificando estado de los recursos...${NC}"
echo ""

echo -e "${BLUE}--- Nodos de Kubernetes ---${NC}"
kubectl get nodes

echo ""
echo -e "${BLUE}--- Pods en namespace $NAMESPACE ---${NC}"
kubectl get pods -n $NAMESPACE

echo ""
echo -e "${BLUE}--- Servicios en namespace $NAMESPACE ---${NC}"
kubectl get svc -n $NAMESPACE

# Obtener IP pública del frontend
echo ""
echo -e "${BLUE}--- Acceso a la aplicación ---${NC}"
FRONTEND_IP=$(kubectl get svc frontend -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)
VM_IP=$(az vm show --resource-group $RESOURCE_GROUP --name $VM_NAME --show-details --query publicIps -o tsv)

if [ -n "$FRONTEND_IP" ]; then
    echo -e "${GREEN}✓ Aplicación de votación: http://$FRONTEND_IP${NC}"
else
    echo -e "${YELLOW}⚠ Esperando asignación de IP pública...${NC}"
fi

if [ -n "$VM_IP" ]; then
    echo -e "${GREEN}✓ Servidor web Nginx: http://$VM_IP${NC}"
else
    echo -e "${YELLOW}⚠ No se pudo obtener la IP de la VM${NC}"
fi

# RESUMEN FINAL
echo ""
echo "=========================================="
echo -e "${GREEN}  ENCENDIDO COMPLETADO${NC}"
echo "=========================================="
echo ""
echo "Estado final:"
check_aks_state
check_vm_state
echo ""
echo -e "${GREEN}✓ Toda la infraestructura está operativa${NC}"
echo ""
