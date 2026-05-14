# 🖥️ Arch Hyprland Config - ArielFalconM 2026

Repositorio personal de configuraciones (**dotfiles**) para Arch Linux, diseñado para un flujo de trabajo productivo, estético y automatizado bajo el compositor **Hyprland**.

> ⚠️ **REQUISITO CRÍTICO:** Este repositorio ha sido refactorizado para utilizar la **API de Lua nativa** de Hyprland. Se requiere tener instalada la **versión 0.55 o superior** del compositor. Los archivos heredados `.conf` han sido eliminados y no son compatibles con la lógica actual.

## 🚀 Instalación desde Cero (Bootstrapping)

El script `install.sh` es el punto de entrada principal diseñado para levantar el sistema operativo desde cero. No solo instala paquetes, sino que automatiza la configuración base y delega el estado final:

- **Provisión de Paquetes:** Compila `yay` si es necesario y procesa listas limpias de dependencias oficiales y de AUR.
- **Tolerancia a Fallos (Fallback):** Intenta una instalación rápida en bloque, pero si detecta paquetes rotos o conflictos, cambia automáticamente a una instalación iterativa (paquete por paquete) para no detener el proceso.
- **Activación de Servicios:** Habilita los demonios del sistema esenciales (`sddm`, `bluetooth`).
- **Traspaso Automático (Hand-off):** Al finalizar la instalación de software de forma exitosa, invoca automáticamente a `deploy.sh` para comenzar la inyección de configuraciones.

## ⚙️ Motor de Despliegue de Precisión

La pieza central de este repositorio es el script `deploy.sh`. A diferencia de los gestores de dotfiles convencionales, este motor utiliza una lógica selectiva segmentada en fases para mantener la integridad del sistema:

- 🏠 **Despliegue de Entorno (Home):** Inyecta archivos base de configuración de usuario directamente en el directorio raíz del usuario.

- ⚡ **Despliegue Atómico:** Enlaza carpetas completas de manera estricta para componentes donde la configuración es controlada íntegramente por el repositorio (Hyprland, Waybar, Kitty, Rofi, Neovim).

- 🧩 **Despliegue Híbrido:** Para aplicaciones con datos volátiles (**Obsidian, Code - OSS**), el script enlaza únicamente los archivos de configuración específicos (`.json`, `.conf`), protegiendo bases de datos y cachés locales.

- 🔐 **Despliegue del Sistema:** Gestiona la copia de archivos que requieren privilegios de administrador (como el gestor de sesión SDDM), empleando lógica idempotente para evitar redundancias.

- 🛡️ **Seguridad y Respaldo:** El sistema detecta archivos reales preexistentes y genera backups automáticos con marca de tiempo (`.bak_YYYYMMDD_HHMMSS`) antes de aplicar cambios.

## 🛠️ Stack Tecnológico

- **WM:** [Hyprland](https://hyprland.org/) (Wayland - API Lua v0.55+)
- **Gestor de Sesión:** SDDM
- **Barra de Estado:** Waybar
- **Terminal:** Kitty
- **Notificaciones:** SwayNC + Scripts personalizados (Bash)
- **Gestor de Archivos:** Nemo
- **Lanzador:** Rofi
- **Editores de texto:** Zed, Code-OSS, Obsidian.

## 📂 Estructura del Proyecto

```text
arch-hyprland-config/
├── home/               # Archivos base de entorno de usuario
├── configs/            # Directorios de configuración destinados a ~/.config
├── scripts/            # Utilidades ejecutables
│   └── laptop_scripts/ # Lógica de hardware exclusiva para dispositivos portátiles
├── icons/              # Iconos individuales inyectados en ~/.local/share/icons
├── system/             # Configuraciones de nivel de sistema (/etc)
├── wallpapers/         # Gestión de fondos de pantalla para Hyprpaper
├── install.sh          # Instalador automatizado de dependencias (Pacman/AUR)
└── deploy.sh           # Motor maestro de sincronización y despliegue de estado
```
