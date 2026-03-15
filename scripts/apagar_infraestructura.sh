#!/bin/bash

# Script para apagar infraestructura de Azure - Caso Práctico 2
# Autor: Julio Eguis Vásquez
# Fecha: Marzo 2026

set -e  # Detener si hay errores

echo "=========================================="
echo "  APAGADO INFRAESTRUCTURA AZURE CP2"
echo "=========================================="
echo ""

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # Sin color

RESOURCE_GROUP="UNIR-casopractico2"
AKS_NAME="aks-casopractico2"
VM_NAME="vm-casopractico2"

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

# PASO 1: Apagar AKS
echo -e "${YELLOW}[1/3] Apagando cluster AKS...${NC}"
check_aks_state

if [[ "$POWER_STATE" == "Running" ]]; then
    echo "Deteniendo AKS..."
    az aks stop --resource-group $RESOURCE_GROUP --name $AKS_NAME
    echo -e "${GREEN}✓ Comando de apagado enviado${NC}"
else
    echo -e "${GREEN}✓ AKS ya está detenido${NC}"
fi

# PASO 2: Esperar a que AKS se detenga completamente
echo ""
echo -e "${YELLOW}[2/3] Esperando confirmación de apagado de AKS...${NC}"
echo "Esto puede tardar 2-3 minutos..."

MAX_ATTEMPTS=30
ATTEMPT=1

while [ $ATTEMPT -le $MAX_ATTEMPTS ]; do
    sleep 10
    POWER_STATE=$(az aks show --resource-group $RESOURCE_GROUP --name $AKS_NAME --query "powerState.code" -o tsv 2>/dev/null)
    
    echo -n "."
    
    if [[ "$POWER_STATE" == "Stopped" ]]; then
        echo ""
        echo -e "${GREEN}✓ AKS completamente detenido${NC}"
        break
    fi
    
    ATTEMPT=$((ATTEMPT + 1))
    
    if [ $ATTEMPT -gt $MAX_ATTEMPTS ]; then
        echo ""
        echo -e "${RED}⚠ Timeout esperando a que AKS se detenga${NC}"
        echo "Verifica manualmente con: az aks show --resource-group $RESOURCE_GROUP --name $AKS_NAME --query powerState"
        exit 1
    fi
done

# PASO 3: Apagar VM
echo ""
echo -e "${YELLOW}[3/3] Apagando máquina virtual...${NC}"
check_vm_state

if [[ "$VM_STATE" != *"deallocated"* ]]; then
    echo "Desasignando VM..."
    az vm deallocate --resource-group $RESOURCE_GROUP --name $VM_NAME
    echo -e "${GREEN}✓ VM desasignada correctamente${NC}"
else
    echo -e "${GREEN}✓ VM ya está desasignada${NC}"
fi

# RESUMEN FINAL
echo ""
echo "=========================================="
echo -e "${GREEN}  APAGADO COMPLETADO${NC}"
echo "=========================================="
echo ""
echo "Estado final:"
check_aks_state
check_vm_state
echo ""
echo -e "${GREEN}✓ Toda la infraestructura está apagada${NC}"
echo -e "${YELLOW}ℹ  Los recursos siguen existiendo (no se eliminaron)${NC}"
echo ""
