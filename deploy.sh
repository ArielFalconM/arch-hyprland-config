#!/bin/bash

# === CONFIGURACIÓN ===
REPO_ROOT="$HOME/arch-setup"
CONFIG_DIR="$REPO_ROOT/configs"
TARGET_DIR="$HOME/.config"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Carpetas HÍBRIDAS: Solo se vinculan archivos específicos del repositorio.
# Evita sobrescribir bases de datos, caché y sesiones locales.
HYBRID_CONFIGS=("onedrive" "Code - OSS" "obsidian")

# === FUNCIONES DE UTILIDAD ===

# Crea un backup solo si el archivo/carpeta destino no es un enlace simbólico
backup_if_real() {
    local path=$1
    if [ -e "$path" ] && [ ! -L "$path" ]; then
        echo "  [WARN] Archivo real detectado. Creando backup: $(basename "$path").bak_$TIMESTAMP"
        mv "$path" "$path.bak_$TIMESTAMP"
    fi
}

# Despliegue híbrido: Vincula únicamente los archivos existentes en el repositorio
deploy_hybrid() {
    local folder=$1
    local repo_source="$CONFIG_DIR/$folder"
    local system_target="$TARGET_DIR/$folder"

    echo ">> Procesando Híbrido: $folder"
    
    mkdir -p "$system_target"

    find "$repo_source" -type f | while read -r repo_file; do
        relative_path="${repo_file#$repo_source/}"
        target_path="$system_target/$relative_path"
        
        mkdir -p "$(dirname "$target_path")"
        backup_if_real "$target_path"
        ln -sf "$repo_file" "$target_path"
        echo "    [INFO] Archivo vinculado: $relative_path"
    done
}

# Despliegue atómico: Vincula el directorio completo
deploy_atomic() {
    local folder=$1
    local repo_source="$CONFIG_DIR/$folder"
    local system_target="$TARGET_DIR/$folder"

    echo ">> Procesando Atómico: $folder"
    
    backup_if_real "$system_target"
    ln -sf "$repo_source" "$system_target"
    echo "    [INFO] Carpeta vinculada con éxito."
}

# === EJECUCIÓN PRINCIPAL ===

echo "=== MOTOR DE DESPLIEGUE ==="
echo "Origen: $CONFIG_DIR"
echo "Destino: $TARGET_DIR"
echo "--------------------------------------------------------"

read -p "¿Desplegar configuraciones exclusivas de laptop? (y/n): " IS_LAPTOP
echo "--------------------------------------------------------"

if [ ! -d "$CONFIG_DIR" ]; then
    echo "[ERROR] No se encuentra el directorio de configuraciones."
    exit 1
fi

cd "$CONFIG_DIR" || exit

for item in *; do

    # Excluir el directorio de configuraciones de laptop según la elección del usuario
    if [ "$item" == "laptop_configs" ]; then
        if [[ ! "$IS_LAPTOP" =~ ^[Yy]$ ]]; then
            echo ">> Saltando $item (Excluido por el usuario)"
            continue
        fi
    fi

    # 1. Manejo de archivos en la raíz
    if [ -f "$item" ]; then
        echo ">> Procesando Archivo: $item"
        backup_if_real "$TARGET_DIR/$item"
        ln -sf "$CONFIG_DIR/$item" "$TARGET_DIR/$item"
        echo "    [INFO] Archivo vinculado con éxito."
        continue
    fi

    # 2. Manejo de directorios
    if [ -d "$item" ]; then
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
echo "=== DESPLIEGUE FINALIZADO ==="