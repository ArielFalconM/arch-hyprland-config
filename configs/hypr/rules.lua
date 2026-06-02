-- rules.lua
---@diagnostic disable: undefined-global


-- REGLAS DE CAPAS (LAYER RULES)

hl.layer_rule({
    name = "waybar",
    match = { namespace = "waybar" },
    blur = true,
    ignore_alpha = 0.1
})

hl.layer_rule({
    match = { namespace = "selection" },
    no_anim = true
})


-- REGLAS DE VENTANAS (WINDOW RULES)

-- Enviar Spotify al workspace 5 en segundo plano
hl.window_rule({
    name = "spotify",
    match = { class = "^([Ss]potify)$" },
    workspace = "5 silent"
})

-- Enviar Steam al workspace 4 en segundo plano
hl.window_rule({
    name = "steam",
    match = { class = "^([Ss]team)$" },
    workspace = "4 silent"
})

-- Hacer que la lista de amigos de Steam flote con un tamaño y posición específicos
hl.window_rule({
    name = "steam-Friends",
    match = {
        class = "^([Ss]team)$",
        title = "^(Friends List)$"
    },
    float = true,
    size = "250 500",
    move = "1225 225"
})

-- Regla para el portal de selección de archivos (File Picker)
hl.window_rule({
    name = "file-picker-portal",
    match = { class = "^(xdg-desktop-portal-gtk)$" },
    float = true,
    size = "900 600"
})

hl.window_rule({
    name = "Overskride",
    match = {
        class = "^(io.github.kaii_lb.Overskride)$",
        title = "^(overskride)$"
    },
    float = true,
    size = "550 650",
    move = "900 150",
    workspace = "current"
})

hl.window_rule({
    name = "nmtui",
    match = {
        class = "^(kitty)$",
        title = "^(nmtui)$",
        initial_title = "^(nmtui)$"
    },
    float = true,
    size = "550 650",
    move = "900 150",
    workspace = "current"
})

hl.window_rule({
    name = "pavucontrol",
    match = {
        class = "^(org.pulseaudio.pavucontrol)$",
        title = "^(Volume Control)$"
    },
    float = true,
    size = "550 650",
    move = "900 150",
    workspace = "current"
})
