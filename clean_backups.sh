#!/bin/bash

echo "=== LIMPIADOR DE BACKUPS ==="
echo "Buscando archivos y carpetas de respaldo (*.bak_*) generados por el motor de despliegue..."

# Rutas donde el deploy.sh podría haber dejado backups
USER_DIRS=("$HOME/.config" "$HOME/.local/bin" "$HOME/.local/share/wallpapers" "$HOME/arch-setup")
SYSTEM_DIRS=("/etc/sddm.conf.d" "/usr/share/sddm/themes/sugar-candy")

# Arrays para capturar los resultados
mapfile -t USER_FILES < <(find "${USER_DIRS[@]}" -name "*.bak_*" 2>/dev/null)
mapfile -t SYSTEM_FILES < <(find "${SYSTEM_DIRS[@]}" -name "*.bak_*" 2>/dev/null)

# Si no hay nada, salimos limpios
if [ ${#USER_FILES[@]} -eq 0 ] && [ ${#SYSTEM_FILES[@]} -eq 0 ]; then
    echo ">> ¡Todo limpio! No se encontraron backups en el sistema."
    exit 0
fi

# Listar lo que se va a borrar
echo -e "\n>> Elementos obsoletos encontrados:"
for file in "${USER_FILES[@]}"; do
    echo "  - $file"
done
for file in "${SYSTEM_FILES[@]}"; do
    echo "  - [Requiere Sudo] $file"
done

echo -e "\n--------------------------------------------------------"
read -p "¿Eliminar permanentemente todos estos backups? (y/N): " CONFIRM

if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo -e "\n>> Ejecutando limpieza profunda..."
    
    # Limpiar entorno de usuario
    if [ ${#USER_FILES[@]} -gt 0 ]; then
        find "${USER_DIRS[@]}" -name "*.bak_*" -exec rm -rf {} + 2>/dev/null
    fi
    
    # Limpiar entorno del sistema (SDDM)
    if [ ${#SYSTEM_FILES[@]} -gt 0 ]; then
        sudo find "${SYSTEM_DIRS[@]}" -name "*.bak_*" -exec rm -rf {} + 2>/dev/null
    fi
    
    echo ">> ¡Limpieza completada con éxito! Tu entorno está impecable."
else
    echo ">> Operación cancelada. Los archivos se mantienen intactos."
fi