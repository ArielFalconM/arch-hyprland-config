---@diagnostic disable: undefined-global

-- Variables de Entorno
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- Variables de Entorno NVIDIA (CRÍTICO para la RTX 2080)
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("GBM_BACKEND", "nvidia-drm")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("VK_ICD_FILENAMES", "/usr/share/vulkan/icd.d/nvidia_icd.json") -- EL PUENTE VULKAN

-- Monitores (Monitor por defecto)
hl.monitor({
    output = "",
    mode = "1920x1080@180hz",
    position = "auto",
    scale = "1"
})

-- XWayland
hl.config({
    xwayland = {
        force_zero_scaling = true
    }
})

-- Inicio Automático
hl.on("hyprland.start", function()
    -- Infraestructura
    hl.exec_cmd("hyprpaper &")                                               --Wallpaper
    hl.exec_cmd("wal -i ~/.local/share/wallpapers/wallpaper -n")             --Paleta de colores Pywal
    hl.exec_cmd("rofi -show drun & sleep 0.1 && pkill rofi")                 --Menu apps bug-fix
    hl.exec_cmd("waybar")                                                    --Barra de estado
    hl.exec_cmd("hypridle")                                                  --Deamon inactividad
    hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")         --Llavero
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1") --gente de autenticación

    --Aplicaciones
    hl.exec_cmd("spotify silent")


    -- Notificadores
    hl.exec_cmd("sleep 5 && swaync -c ~/.config/swaync/config.json -s ~/.config/swaync/style.css") --Notificaciones
    hl.exec_cmd(" ~/.local/bin/spotify_notify.sh &")
    hl.exec_cmd("~/.local/bin/usb_notify.sh &")
    hl.exec_cmd("~/.local/bin/wifi_notify.sh &")
    hl.exec_cmd("~/.local/bin/bluetooth_notify.sh &")
end)
