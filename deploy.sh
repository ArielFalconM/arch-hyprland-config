#!/bin/bash

set -euo pipefail

# === CONFIGURACIÓN ===
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$REPO_ROOT/configs"
TARGET_DIR="$HOME/.config"

SCRIPTS_DIR="$REPO_ROOT/scripts"
BIN_TARGET="$HOME/.local/bin"

ICONS_DIR="$REPO_ROOT/icons"
ICONS_TARGET="$HOME/.local/share/icons"

# Nueva configuración para imágenes y sistema
WALLPAPERS_DIR="$REPO_ROOT/wallpapers"
WALLPAPER_TARGET="$HOME/.local/share/wallpapers"
SYSTEM_DIR="$REPO_ROOT/system"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# === FUNCIONES DE UTILIDAD ===

backup_if_real() {
    local path=$1
    if [ -L "$path" ] && [ ! -e "$path" ]; then
        rm "$path"
    elif [ -e "$path" ] && [ ! -L "$path" ]; then
        echo "  [WARN] Archivo real detectado. Creando backup: $(basename "$path").bak_$TIMESTAMP"
        if [ -w "$(dirname "$path")" ]; then
            mv "$path" "$path.bak_$TIMESTAMP"
        else
            sudo mv "$path" "$path.bak_$TIMESTAMP" || echo "  [ERROR] No se pudo hacer backup de $path"
        fi
    fi
}

deploy_hybrid() {
    local repo_source=$1
    local system_target=$2

    echo ">> Procesando Híbrido: $(basename "$repo_source")"
    mkdir -p "$system_target"

    while IFS= read -r -d '' repo_file; do
        local relative_path="${repo_file#$repo_source/}"
        local target_path="$system_target/$relative_path"

        if [ "$(basename "$repo_file")" == ".hybrid" ]; then continue; fi

        mkdir -p "$(dirname "$target_path")"
        backup_if_real "$target_path"
        ln -sf "$repo_file" "$target_path"
        echo "    [INFO] Archivo vinculado: $relative_path"
    done < <(find "$repo_source" -type f -print0)
}

deploy_atomic() {
    local repo_source=$1
    local system_target=$2

    echo ">> Procesando Atómico: $(basename "$repo_source")"
    backup_if_real "$system_target"
    # Flag -n para evitar enlaces recursivos
    ln -sfn "$repo_source" "$system_target"
    echo "    [INFO] Carpeta vinculada con éxito."
}

deploy_module() {
    local source_path=$1
    local target_path=$2

    if [ -f "$source_path/.hybrid" ]; then
        deploy_hybrid "$source_path" "$target_path"
    else
        deploy_atomic "$source_path" "$target_path"
    fi
}

# === EJECUCIÓN PRINCIPAL ===

echo "=== MOTOR DE DESPLIEGUE ==="
echo "Repo: $REPO_ROOT"
echo "--------------------------------------------------------"

echo "¿En qué hardware se está desplegando Arch-Nemesis?"
echo "1) Laptop (Gráficos integrados / Batería)"
echo "2) PC Torre (NVIDIA)"
read -rp "Selecciona una opción [1/2]: " HW_CHOICE || true

if [[ "$HW_CHOICE" != "1" && "$HW_CHOICE" != "2" ]]; then
    echo "    [ERROR] Entrada inválida ('$HW_CHOICE'). Abortando despliegue."
    exit 1
fi

if [ "$HW_CHOICE" == "2" ]; then
    ACTIVE_PROFILE="torre"
    INACTIVE_PROFILE="laptop"
    echo "    [INFO] Perfil asignado: TORRE."
else
    ACTIVE_PROFILE="laptop"
    INACTIVE_PROFILE="torre"
    echo "    [INFO] Perfil asignado: LAPTOP."
fi
echo "--------------------------------------------------------"

# ---------------------------------------------------------
# FASE 0: DESPLIEGUE DE ARCHIVOS DE HOME (~/)
# ---------------------------------------------------------
HOME_REPO_DIR="$REPO_ROOT/home"

if [ -d "$HOME_REPO_DIR" ]; then
    echo -e "\n=== FASE 0: INYECTANDO ARCHIVOS DE HOME ==="

    while IFS= read -r -d '' file; do
        base_name=$(basename "$file")
        echo ">> Procesando archivo de Home: $base_name"
        backup_if_real "$HOME/$base_name"
        ln -sf "$file" "$HOME/$base_name"
        echo "    [INFO] Archivo vinculado: $base_name"
    done < <(find "$HOME_REPO_DIR" -mindepth 1 -maxdepth 1 -type f -print0)
fi

# ---------------------------------------------------------
# FASE 1: DESPLIEGUE DE CONFIGURACIONES (~/.config)
# ---------------------------------------------------------
if [ -d "$CONFIG_DIR" ]; then
    echo -e "\n=== FASE 1: INYECTANDO CONFIGURACIONES ==="
    mkdir -p "$TARGET_DIR"

    # Parte A: Despliegue Base
    while IFS= read -r -d '' item; do
        base_name=$(basename "$item")

        if [[ "$base_name" == *_configs ]]; then continue; fi

        if [ -f "$item" ]; then
            echo ">> Procesando Archivo: $base_name"
            backup_if_real "$TARGET_DIR/$base_name"
            ln -sf "$item" "$TARGET_DIR/$base_name"
            echo "    [INFO] Archivo vinculado con éxito."
        elif [ -d "$item" ]; then
            deploy_module "$item" "$TARGET_DIR/$base_name"
        fi
    done < <(find "$CONFIG_DIR" -mindepth 1 -maxdepth 1 -print0)

    # Parte B: Inyección de Overrides (Perfiles)
    PROFILE_DIR="$CONFIG_DIR/${ACTIVE_PROFILE}_configs"
    if [ -d "$PROFILE_DIR" ]; then
        echo -e "\n>> Sobrescribiendo con configuraciones de perfil: $ACTIVE_PROFILE"
        while IFS= read -r -d '' override; do
            base_name=$(basename "$override")
            echo "    [INFO] Aplicando override para: $base_name"

            if [ -f "$override" ]; then
                backup_if_real "$TARGET_DIR/$base_name"
                ln -sf "$override" "$TARGET_DIR/$base_name"
            elif [ -d "$override" ]; then
                deploy_module "$override" "$TARGET_DIR/$base_name"
            fi
        done < <(find "$PROFILE_DIR" -mindepth 1 -maxdepth 1 -print0)
    fi
fi

# ---------------------------------------------------------
# FASE 2: DESPLIEGUE DE SCRIPTS (~/.local/bin)
# ---------------------------------------------------------
if [ -d "$SCRIPTS_DIR" ]; then
    echo -e "\n=== FASE 2: INYECTANDO SCRIPTS ==="
    mkdir -p "$BIN_TARGET"

    while IFS= read -r -d '' item; do
        base_name=$(basename "$item")

        if [ -d "$item" ]; then
            if [ "$base_name" == "${ACTIVE_PROFILE}_scripts" ]; then
                while IFS= read -r -d '' host_script; do
                    script_name=$(basename "$host_script")
                    echo ">> Procesando Script de Perfil: $script_name"
                    backup_if_real "$BIN_TARGET/$script_name"
                    ln -sf "$host_script" "$BIN_TARGET/$script_name"
                done < <(find "$item" -mindepth 1 -maxdepth 1 -type f -print0)
            fi
            continue
        fi

        if [ -f "$item" ]; then
            echo ">> Procesando Script Base: $base_name"
            backup_if_real "$BIN_TARGET/$base_name"
            ln -sf "$item" "$BIN_TARGET/$base_name"
        fi
    done < <(find "$SCRIPTS_DIR" -mindepth 1 -maxdepth 1 -print0)
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
    mkdir -p "$WALLPAPER_TARGET"

    while IFS= read -r -d '' wp; do
        base_name=$(basename "$wp")
        backup_if_real "$WALLPAPER_TARGET/$base_name"
        ln -sf "$wp" "$WALLPAPER_TARGET/$base_name"
        echo "    [INFO] Imagen vinculada con éxito."
    done < <(find "$WALLPAPERS_DIR" -mindepth 1 -maxdepth 1 -type f -print0)
fi

# ---------------------------------------------------------
# FASE 3.5: DESPLIEGUE DE ICONOS (~/.local/share/icons)
# ---------------------------------------------------------
if [ -d "$ICONS_DIR" ]; then
    echo -e "\n=== FASE 3.5: INYECTANDO ICONOS ==="
    mkdir -p "$ICONS_TARGET"

    while IFS= read -r -d '' icon; do
        base_name=$(basename "$icon")
        backup_if_real "$ICONS_TARGET/$base_name"
        ln -sf "$icon" "$ICONS_TARGET/$base_name"
        echo "    [INFO] Icono $base_name vinculado con éxito."
    done < <(find "$ICONS_DIR" -mindepth 1 -maxdepth 1 -type f -print0)
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

        if sudo -v 2>/dev/null; then
            # 1. Copiar el archivo principal que activa el tema
            if [ -f "$SYSTEM_DIR/sddm/sugar-candy.conf" ]; then
                sudo mkdir -p /etc/sddm.conf.d
                if ! cmp -s "$SYSTEM_DIR/sddm/sugar-candy.conf" "/etc/sddm.conf.d/sugar-candy.conf" 2>/dev/null; then
                    backup_if_real "/etc/sddm.conf.d/sugar-candy.conf"
                    sudo cp "$SYSTEM_DIR/sddm/sugar-candy.conf" /etc/sddm.conf.d/ && echo "    [INFO] Archivo de activación de tema copiado." || echo "    [WARN] Falló la copia de sugar-candy.conf"
                fi
            fi

            # 2. Copiar configuraciones específicas del tema Sugar Candy
            SUGAR_DIR="/usr/share/sddm/themes/sugar-candy"
            if [ -d "$SUGAR_DIR" ]; then
                if [ -f "$SYSTEM_DIR/sddm/theme.conf" ] && ! cmp -s "$SYSTEM_DIR/sddm/theme.conf" "$SUGAR_DIR/theme.conf" 2>/dev/null; then
                    backup_if_real "$SUGAR_DIR/theme.conf"
                    sudo cp "$SYSTEM_DIR/sddm/theme.conf" "$SUGAR_DIR/" && echo "    [INFO] Configuración de Sugar Candy copiada." || echo "    [WARN] Falló la copia de theme.conf"
                fi

                if [ -f "$SYSTEM_DIR/sddm/sddm_wallpaper.jpg" ] && ! cmp -s "$SYSTEM_DIR/sddm/sddm_wallpaper.jpg" "$SUGAR_DIR/Backgrounds/sddm_wallpaper.jpg" 2>/dev/null; then
                    backup_if_real "$SUGAR_DIR/Backgrounds/sddm_wallpaper.jpg"
                    sudo mkdir -p "$SUGAR_DIR/Backgrounds"
                    sudo cp "$SYSTEM_DIR/sddm/sddm_wallpaper.jpg" "$SUGAR_DIR/Backgrounds/" && echo "    [INFO] Wallpaper de login copiado." || echo "    [WARN] Falló la copia del wallpaper."
                fi
            else
                echo "    [WARN] El tema Sugar Candy no está en $SUGAR_DIR."
                echo "    Asegúrate de que el paquete de AUR se haya instalado correctamente."
            fi
        else
            echo "    [WARN] Permisos denegados (Sudo). Saltando inyección de SDDM."
        fi
    fi
fi

# ---------------------------------------------------------
# FASE 5: RECONCILIACIÓN (Limpieza de Drift)
# ---------------------------------------------------------
echo -e "\n=== FASE 5: LIMPIEZA DE DRIFT ==="
echo ">> Buscando enlaces simbólicos huérfanos y de perfiles inactivos..."

while IFS= read -r -d '' link; do
    target=$(readlink "$link")

    if [[ "$target" == "$REPO_ROOT"* ]] && [ ! -e "$target" ]; then
        rm "$link"
        echo "    [INFO] Enlace muerto eliminado: $link"
    elif [[ "$target" == *"${INACTIVE_PROFILE}_configs"* ]] || [[ "$target" == *"${INACTIVE_PROFILE}_scripts"* ]]; then
        rm "$link"
        echo "    [INFO] Enlace de perfil inactivo ($INACTIVE_PROFILE) eliminado: $link"
    fi
done < <(find "$TARGET_DIR" "$BIN_TARGET" "$ICONS_TARGET" -type l -print0 2>/dev/null)

echo "--------------------------------------------------------"
echo "=== DESPLIEGUE FINALIZADO ==="
