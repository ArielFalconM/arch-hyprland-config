#!/bin/bash

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}=== Construyendo entorno Arch Linux ===${NC}\n"

# Solicitar privilegios de administrador
sudo -v

# Mantener los privilegios de sudo activos durante la ejecución del script
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &


echo -e "\n=== PREPARANDO GESTOR DE PAQUETES ==="

# 1. Habilitar el repositorio multilib en pacman.conf
if grep -q "^#\[multilib\]" /etc/pacman.conf; then
    echo ">> Habilitando el repositorio [multilib] para soporte de 32 bits (Steam)..."
    # Descomenta la cabecera [multilib] y la línea Include inmediatamente inferior
    sudo sed -i '/^#\[multilib\]/ { s/^#//; n; s/^#//; }' /etc/pacman.conf

    # Sincronizar las bases de datos luego del cambio
    sudo pacman -Sy
else
    echo ">> El repositorio [multilib] ya está habilitado."
fi


# ---------------------------------------------------------
# 1. PREPARACIÓN DEL SISTEMA Y GESTOR AUR
# ---------------------------------------------------------
echo -e "${BLUE}[1/4] Instalando dependencias base y yay...${NC}"
sudo pacman -Syu --needed --noconfirm base-devel git

if ! command -v yay &> /dev/null; then
    echo -e "${YELLOW}Compilando yay desde AUR...${NC}"
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay
    makepkg -si --noconfirm
    cd - > /dev/null
    rm -rf /tmp/yay
else
    echo -e "${GREEN}yay ya está instalado.${NC}"
fi

# ---------------------------------------------------------
# 2. LECTURA Y LIMPIEZA DE LISTAS DE PAQUETES
# ---------------------------------------------------------
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ARCHIVO_OFICIALES="$REPO_DIR/Pacman.txt"
ARCHIVO_AUR="$REPO_DIR/AUR.txt"

if [ ! -f "$ARCHIVO_OFICIALES" ] || [ ! -f "$ARCHIVO_AUR" ]; then
    echo -e "${RED}[ERROR] Faltan los archivos Pacman.txt o AUR.txt${NC}"
    exit 1
fi

# sed elimina saltos de línea de Windows (\r), comentarios (#) y líneas vacías
PAQUETES_OFICIALES=($(sed -e 's/\r//g' -e 's/#.*//' -e '/^$/d' "$ARCHIVO_OFICIALES"))
PAQUETES_AUR=($(sed -e 's/\r//g' -e 's/#.*//' -e '/^$/d' "$ARCHIVO_AUR"))

# ---------------------------------------------------------
# 3. INSTALACIÓN DE SOFTWARE (SISTEMA DE RESCATE)
# ---------------------------------------------------------
echo -e "\n${BLUE}[2/4] Sincronizando e instalando repositorios oficiales...${NC}"
# Intento 1: Todos de golpe
if ! sudo pacman -S --needed --noconfirm "${PAQUETES_OFICIALES[@]}"; then
    echo -e "${YELLOW}[WARN] Algún paquete falló. Activando instalación uno a uno...${NC}"
    for pkg in "${PAQUETES_OFICIALES[@]}"; do
        sudo pacman -S --needed --noconfirm "$pkg" || echo -e "${RED}>> ERROR crítico con: $pkg${NC}"
    done
fi

echo -e "\n${BLUE}[3/4] Construyendo e instalando paquetes de AUR...${NC}"
if ! yay -S --needed --noconfirm "${PAQUETES_AUR[@]}"; then
    echo -e "${YELLOW}[WARN] Algún paquete de AUR falló. Activando instalación uno a uno...${NC}"
    for pkg in "${PAQUETES_AUR[@]}"; do
        yay -S --needed --noconfirm "$pkg" || echo -e "${RED}>> ERROR crítico con: $pkg${NC}"
    done
fi

# ---------------------------------------------------------
# 4. HABILITAR SERVICIOS DEL SISTEMA
# ---------------------------------------------------------
echo -e "\n${BLUE}[4/4] Levantando servicios del sistema...${NC}"
sudo systemctl enable sddm
sudo systemctl enable bluetooth
# El servicio de OneDrive fue eliminado a petición.

# ---------------------------------------------------------
# 5. INYECCIÓN DE DOTFILES
# ---------------------------------------------------------
echo -e "\n${BLUE}=== Conectando Configuraciones (Deploy) ===${NC}"
if [ -f "$REPO_DIR/deploy.sh" ]; then
    chmod +x "$REPO_DIR/deploy.sh"
    "$REPO_DIR/deploy.sh"
else
    echo -e "${RED}[ERROR] No se encontró deploy.sh${NC}"
fi

echo -e "\n${GREEN}=== ARQUITECTURA DESPLEGADA CON ÉXITO ===${NC}"
echo "El sistema está listo. Reiniciar la máquina para aplicar todos los cambios."
