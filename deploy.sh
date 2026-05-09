#!/bin/bash

# === CONFIGURACIÓN ===
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$REPO_ROOT/configs"
TARGET_DIR="$HOME/.config"

SCRIPTS_DIR="$REPO_ROOT/scripts"
BIN_TARGET="$HOME/.local/bin"

# Nueva configuración para imágenes y sistema
WALLPAPERS_DIR="$REPO_ROOT/wallpapers"
WALLPAPER_TARGET="$HOME/.local/share/wallpapers"
SYSTEM_DIR="$REPO_ROOT/system"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)

HYBRID_CONFIGS=("Code - OSS" "obsidian" "gtk-4.0" "zed")

# === FUNCIONES DE UTILIDAD ===

backup_if_real() {
    local path=$1
    if [ -e "$path" ] && [ ! -L "$path" ]; then
        echo "  [WARN] Archivo real detectado. Creando backup: $(basename "$path").bak_$TIMESTAMP"
        if [ -w "$(dirname "$path")" ]; then
            mv "$path" "$path.bak_$TIMESTAMP"
        else
            sudo mv "$path" "$path.bak_$TIMESTAMP"
        fi
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
    # Flag -n para evitar enlaces recursivos
    ln -sfn "$repo_source" "$system_target"
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
        [ -e "$item" ] || continue

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
        [ -e "$script" ] || continue

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
# FASE 3: DESPLIEGUE DE WALLPAPERS (~/.local/share/wallpapers)
# ---------------------------------------------------------

# PREPARACIÓN DE CARPETAS DE USUARIO:
echo -e "\n=== VERIFICANDO DIRECTORIOS BASE ==="
SCREENSHOTS_DIR="$HOME/Pictures/Screenshots"

mkdir -p "$SCREENSHOTS_DIR"
echo "    [INFO] Directorio de capturas asegurado en $SCREENSHOTS_DIR"

if [ -d "$WALLPAPERS_DIR" ]; then
    echo -e "\n=== FASE 3: INYECTANDO WALLPAPERS ==="
    # Creamos la ruta genérica si no existe
    mkdir -p "$WALLPAPER_TARGET"
    cd "$WALLPAPERS_DIR" || exit

    for wp in *; do
        [ -e "$wp" ] || continue # Evita errores si la carpeta está vacía

        if [ -f "$wp" ]; then
            echo ">> Procesando Wallpaper: $wp"
            backup_if_real "$WALLPAPER_TARGET/$wp"
            ln -sf "$WALLPAPERS_DIR/$wp" "$WALLPAPER_TARGET/$wp"
            echo "    [INFO] Imagen vinculada con éxito."
        fi
    done
fi

# ---------------------------------------------------------
# FASE 4: DESPLIEGUE DEL SISTEMA
# ---------------------------------------------------------
if [ -d "$SYSTEM_DIR" ]; then
    echo -e "\n=== FASE 4: INYECTANDO CONFIGURACIONES DEL SISTEMA ==="
    echo ">> Esta fase requiere permisos de administrador para modificar el sistema."

    # --- Configuración de SDDM ---
    if [ -d "$SYSTEM_DIR/sddm" ]; then
        echo ">> Configurando gestor de sesión (SDDM)..."

        # 1. Copiar el archivo principal que activa el tema
        if [ -f "$SYSTEM_DIR/sddm/sugar-candy.conf" ]; then
            sudo mkdir -p /etc/sddm.conf.d
            # 'cmp -s' compara los archivos y solo hace el backup/copia si son diferentes
            if ! cmp -s "$SYSTEM_DIR/sddm/sugar-candy.conf" "/etc/sddm.conf.d/sugar-candy.conf" 2>/dev/null; then
                backup_if_real "/etc/sddm.conf.d/sugar-candy.conf"
                sudo cp "$SYSTEM_DIR/sddm/sugar-candy.conf" /etc/sddm.conf.d/
                echo "    [INFO] Archivo de activación de tema copiado."
            fi
        fi

        # 2. Copiar configuraciones específicas del tema Sugar Candy
        SUGAR_DIR="/usr/share/sddm/themes/sugar-candy"
        if [ -d "$SUGAR_DIR" ]; then
            # Copiar la configuración del tema
            if [ -f "$SYSTEM_DIR/sddm/theme.conf" ]; then
                if ! cmp -s "$SYSTEM_DIR/sddm/theme.conf" "$SUGAR_DIR/theme.conf" 2>/dev/null; then
                    backup_if_real "$SUGAR_DIR/theme.conf"
                    sudo cp "$SYSTEM_DIR/sddm/theme.conf" "$SUGAR_DIR/"
                    echo "    [INFO] Configuración de Sugar Candy copiada."
                fi
            fi

            # Copiar el wallpaper al directorio del tema
            if [ -f "$SYSTEM_DIR/sddm/sddm_wallpaper.jpg" ]; then
                if ! cmp -s "$SYSTEM_DIR/sddm/sddm_wallpaper.jpg" "$SUGAR_DIR/Backgrounds/sddm_wallpaper.jpg" 2>/dev/null; then
                    backup_if_real "$SUGAR_DIR/Backgrounds/sddm_wallpaper.jpg"
                    sudo mkdir -p "$SUGAR_DIR/Backgrounds"
                    sudo cp "$SYSTEM_DIR/sddm/sddm_wallpaper.jpg" "$SUGAR_DIR/Backgrounds/"
                    echo "    [INFO] Wallpaper de login copiado."
                fi
            fi
        else
            echo "    [WARN] El tema Sugar Candy no está en $SUGAR_DIR."
            echo "    Asegúrate de que el paquete de AUR se haya instalado correctamente."
        fi
    fi
fi

echo "--------------------------------------------------------"
echo "=== DESPLIEGUE FINALIZADO ==="
