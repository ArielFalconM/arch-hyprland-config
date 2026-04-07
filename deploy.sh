#!/bin/bash

# === CONFIGURACIÓN ===
REPO_ROOT="$HOME/arch-setup"
CONFIG_DIR="$REPO_ROOT/configs"
TARGET_DIR="$HOME/.config"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Carpetas HÍBRIDAS: Solo linkeamos archivos específicos del repo.
# Esto mantiene tus bases de datos, caché y sesiones locales intactas.
HYBRID_CONFIGS=("onedrive" "Code - OSS" "obsidian")

# === FUNCIONES DE UTILIDAD ===

# Crea un backup solo si el archivo/carpeta es real
backup_if_real() {
    local path=$1
    if [ -e "$path" ] && [ ! -L "$path" ]; then
        echo "  [WARN] Real detectado en sistema. Creando backup: $(basename "$path").bak_$TIMESTAMP"
        mv "$path" "$path.bak_$TIMESTAMP"
    fi
}

# Despliegue de precisión: Entra en la carpeta y linkea solo los archivos que existen en el repo
deploy_hybrid() {
    local folder=$1
    local repo_source="$CONFIG_DIR/$folder"
    local system_target="$TARGET_DIR/$folder"

    echo ">> Procesando Híbrido (archivo por archivo): $folder"
    
    # Aseguramos que la carpeta real exista en .config 
    mkdir -p "$system_target"

    # Buscamos todos los archivos dentro de la carpeta del repositorio
    find "$repo_source" -type f | while read -r repo_file; do
        # Calculamos la ruta relativa
        relative_path="${repo_file#$repo_source/}"
        target_path="$system_target/$relative_path"
        
        # Aseguramos que el subdirectorio exista en el destino
        mkdir -p "$(dirname "$target_path")"

        # Backup si el archivo destino es real
        backup_if_real "$target_path"

        # Crear enlace simbólico forzado
        ln -sf "$repo_file" "$target_path"
        echo "    [INFO] Archivo vinculado: $relative_path"
    done
}

# Despliegue atómico: Linkea la carpeta entera
deploy_atomic() {
    local folder=$1
    local repo_source="$CONFIG_DIR/$folder"
    local system_target="$TARGET_DIR/$folder"

    echo ">> Procesando Atómico (carpeta completa): $folder"
    
    backup_if_real "$system_target"
    ln -sf "$repo_source" "$system_target"
    echo "    [INFO] Carpeta vinculada con éxito."
}

# === EJECUCIÓN PRINCIPAL ===

echo "=== MOTOR DE DESPLIEGUE DE PRECISIÓN v3.1 (Ariel Edition) ==="
echo "Origen: $CONFIG_DIR"
echo "Destino: $TARGET_DIR"
echo "--------------------------------------------------------"

# Entrar a la carpeta de configs del repo
if [ ! -d "$CONFIG_DIR" ]; then
    echo "[ERROR] No se encuentra la carpeta de configuraciones en el repositorio."
    exit 1
fi

cd "$CONFIG_DIR" || exit

for item in *; do
    # 1. Manejo de ARCHIVOS SUELTOS en la raíz de configs 
    if [ -f "$item" ]; then
        echo ">> Procesando Archivo Suelto: $item"
        backup_if_real "$TARGET_DIR/$item"
        ln -sf "$CONFIG_DIR/$item" "$TARGET_DIR/$item"
        echo "    [INFO] Archivo vinculado con éxito."
        continue
    fi

    # 2. Manejo de CARPETAS
    if [ -d "$item" ]; then
        # Verificar si la carpeta está marcada como híbrida
        is_hybrid=false
        for h in "${HYBRID_CONFIGS[@]}"; do
            [[ "$h" == "$item" ]] && is_hybrid=true && break
        done

        if [ "$is_hybrid" = true ]; then
            deploy_hybrid "$item"
        else
            deploy_atomic "$item"
        fi
    fi
done

echo "--------------------------------------------------------"
echo "=== DESPLIEGUE FINALIZADO CON ÉXITO ==="