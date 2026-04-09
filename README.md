#  Arch Hyprland Config - ArielFalconM 2026

Repositorio personal de configuraciones (**dotfiles**) para Arch Linux, diseñado para un flujo de trabajo productivo, estético y automatizado bajo el compositor **Hyprland**.

##  Motor de Despliegue de Precisión
La pieza central de este repositorio es el script `deploy.sh`. A diferencia de los gestores de dotfiles convencionales, este motor utiliza una lógica selectiva para mantener el sistema limpio y funcional:

- **Despliegue Atómico:** Enlaza carpetas completas para componentes donde la configuración es 100% estática (Hyprland, Waybar, Kitty, Rofi, Neovim).
- **Despliegue Híbrido:** Para aplicaciones que generan datos volátiles o sesiones activas (**Obsidian, Code - OSS, OneDrive**), el script solo enlaza los archivos de configuración específicos (.json, .conf), protegiendo las bases de datos, cachés y tokens locales del usuario.
- **Despliegue del Sistema:** Copia de forma segura y comprobada configuraciones que requieren privilegios de administrador (como el gestor de sesión), usando lógica idempotente para no duplicar procesos.
- **Seguridad Integrada:** Antes de realizar cualquier cambio, el sistema detecta si existen archivos reales y crea backups automáticos con *timestamp* (`.bak_YYYYMMDD_HHMMSS`) gestionando los permisos de sudo de forma inteligente.

## 📦 Stack Tecnológico
- **WM:** [Hyprland](https://hyprland.org/) (Wayland)
- **Gestor de Sesión:** SDDM (Tema Sugar Candy)
- **Barra:** Waybar (CSS personalizado)
- **Terminal:** Kitty
- **Notificaciones:** SwayNC + Scripts personalizados (Bash)
- **File Manager:** Nemo
- **Lanzador:** Rofi (Wayland fork)
- **Editor:** Neovim & Code - OSS

## 📂 Estructura del Proyecto
```text
arch-setup/
├── configs/          # Archivos de configuración destinados a ~/.config
├── scripts/          # Scripts de utilidad (Bluetooth, Wifi, Spotify)
│   └── laptop_scripts/ # Lógica de energía y batería para laptops
├── system/           # Configuraciones a nivel de sistema que requieren sudo
├── wallpapers/       # Gestión de fondos de pantalla
├── install.sh        # Instalador de dependencias y paquetes (Pacman/AUR)
└── deploy.sh         # Motor de sincronización por enlaces y copias del sistema