#!/bin/bash

# === CONFIGURACIÓN ===
REPO_ROOT="$HOME/arch-setup"
CONFIG_DIR="$REPO_ROOT/configs"
TARGET_DIR="$HOME/.config"

SCRIPTS_DIR="$REPO_ROOT/scripts"
BIN_TARGET="$HOME/.local/bin"

# Nueva configuración para imágenes
WALLPAPERS_DIR="$REPO_ROOT/wallpapers"
PICTURES_TARGET="$HOME/Pictures"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)

HYBRID_CONFIGS=("onedrive" "Code - OSS" "obsidian")

# === FUNCIONES DE UTILIDAD ===

backup_if_real() {
    local path=$1
    if [ -e "$path" ] && [ ! -L "$path" ]; then
        echo "  [WARN] Archivo real detectado. Creando backup: $(basename "$path").bak_$TIMESTAMP"
        mv "$path" "$path.bak_$TIMESTAMP"
    fi
}

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
echo "Repo: $REPO_ROOT"
echo "--------------------------------------------------------"

read -p "¿Desplegar configuraciones exclusivas de laptop? (y/n): " IS_LAPTOP
echo "--------------------------------------------------------"

# ---------------------------------------------------------
# FASE 1: DESPLIEGUE DE CONFIGURACIONES (~/.config)
# ---------------------------------------------------------
if [ -d "$CONFIG_DIR" ]; then
    echo -e "\n=== FASE 1: INYECTANDO CONFIGURACIONES ==="
    cd "$CONFIG_DIR" || exit

    for item in *; do
        if [ "$item" == "laptop_configs" ]; then
            if [[ ! "$IS_LAPTOP" =~ ^[Yy]$ ]]; then
                echo ">> Saltando $item (Excluido por el usuario)"
                continue
            fi
        fi

        if [ -f "$item" ]; then
            echo ">> Procesando Archivo: $item"
            backup_if_real "$TARGET_DIR/$item"
            ln -sf "$CONFIG_DIR/$item" "$TARGET_DIR/$item"
            echo "    [INFO] Archivo vinculado con éxito."
            continue
        fi

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
fi

# ---------------------------------------------------------
# FASE 2: DESPLIEGUE DE SCRIPTS (~/.local/bin)
# ---------------------------------------------------------
if [ -d "$SCRIPTS_DIR" ]; then
    echo -e "\n=== FASE 2: INYECTANDO SCRIPTS ==="
    mkdir -p "$BIN_TARGET"
    cd "$SCRIPTS_DIR" || exit

    for script in *; do
        if [ "$script" == "laptop_scripts" ]; then
            if [[ ! "$IS_LAPTOP" =~ ^[Yy]$ ]]; then
                echo ">> Saltando scripts de laptop (Excluido por el usuario)"
                continue
            fi
            
            for laptop_script in "$SCRIPTS_DIR/laptop_scripts/"*; do
                [ -e "$laptop_script" ] || continue
                base_name=$(basename "$laptop_script")
                echo ">> Procesando Script de Laptop: $base_name"
                backup_if_real "$BIN_TARGET/$base_name"
                ln -sf "$laptop_script" "$BIN_TARGET/$base_name"
                chmod +x "$BIN_TARGET/$base_name"
            done
            continue
        fi

        if [ -f "$script" ]; then
            echo ">> Procesando Script: $script"
            backup_if_real "$BIN_TARGET/$script"
            ln -sf "$SCRIPTS_DIR/$script" "$BIN_TARGET/$script"
            chmod +x "$BIN_TARGET/$script"
        fi
    done
fi

# ---------------------------------------------------------
# FASE 3: DESPLIEGUE DE WALLPAPERS (~/Pictures)
# ---------------------------------------------------------
if [ -d "$WALLPAPERS_DIR" ]; then
    echo -e "\n=== FASE 3: INYECTANDO WALLPAPERS ==="
    mkdir -p "$PICTURES_TARGET"
    cd "$WALLPAPERS_DIR" || exit

    for wp in *; do
        if [ -f "$wp" ]; then
            echo ">> Procesando Wallpaper: $wp"
            backup_if_real "$PICTURES_TARGET/$wp"
            ln -sf "$WALLPAPERS_DIR/$wp" "$PICTURES_TARGET/$wp"
            echo "    [INFO] Imagen vinculada con éxito."
        fi
    done
fi

echo "--------------------------------------------------------"
echo "=== DESPLIEGUE FINALIZADO ==="