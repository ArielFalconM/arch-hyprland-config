---@diagnostic disable: undefined-global

-- Variables de Entorno
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- Monitores (Monitor por defecto)
hl.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = "1.25"
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
    hl.exec_cmd("~/.local/bin/laptop_monitor.sh")
    hl.exec_cmd("swaybg -i ~/.local/share/wallpapers/wallpaper -m fill &")
    hl.exec_cmd("wal -i ~/.local/share/wallpapers/wallpaper -n")
    hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")
    hl.exec_cmd("rofi -show drun & sleep 0.1 && pkill rofi")
    hl.exec_cmd("waybar")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("swaync -c ~/.config/swaync/config.json -s ~/.config/swaync/style.css")
    hl.exec_cmd("bash -ic 'zettel'")

    -- Notificadores
    hl.exec_cmd(" ~/.local/bin/spotify_notify.sh &")
    hl.exec_cmd("~/.local/bin/usb_notify.sh &")
    hl.exec_cmd("~/.local/bin/wifi_notify.sh &")
    hl.exec_cmd("~/.local/bin/bat_notify.sh &")
    hl.exec_cmd("~/.local/bin/bluetooth_notify.sh &")
    hl.exec_cmd("~/.local/bin/power_profile_notify.sh &")
end)
