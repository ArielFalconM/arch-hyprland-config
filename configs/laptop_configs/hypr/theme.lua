-- theme.lua
-- Configuración visual y de comportamiento del sistema
---@diagnostic disable: undefined-global


hl.config({
    general = {
        gaps_in = 3,
        gaps_out = 10,
        border_size = 2,
        ["col.active_border"] = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
        ["col.inactive_border"] = "rgba(595959aa)",
        resize_on_border = true,
        allow_tearing = false,
        layout = "dwindle"
    },
    decoration = {
        rounding = 10,
        rounding_power = 2,
        active_opacity = 1.0,
        inactive_opacity = 1.0,
        shadow = {
            enabled = true,
            range = 4,
            render_power = 3,
            color = 0xee1a1a1a
        },
        blur = {
            enabled = true,
            size = 8,
            passes = 1,
            vibrancy = 0.1696
        }
    },
    animations = {
        enabled = true
    },
    input = {
        kb_layout = "us",
        follow_mouse = 1,
        sensitivity = 0,
        touchpad = {
            natural_scroll = true,
            tap_to_click = true,
            scroll_factor = 0.3
        }
    },
    dwindle = {
        preserve_split = true
    },
    master = {
        new_status = "master"
    },
    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo = true,
        mouse_move_enables_dpms = true,
        key_press_enables_dpms = true
    },
    xwayland = {
        force_zero_scaling = true
    }
})


-- GESTOS Y DISPOSITIVOS ESPECÍFICOS

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

hl.device({
    name = "epic-mouse-v1",
    sensitivity = -0.5
})

-- MOTOR DE ANIMACIONES: Curvas Bézier (hl.curve)

hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })
hl.curve("easePersonal", { type = "bezier", points = { { 0.65, 0.34 }, { 0.46, 0.83 } } })
hl.curve("partialLinear", { type = "bezier", points = { { 0.28, 0.51 }, { 0.44, 0.66 } } })
hl.curve("promontory", { type = "bezier", points = { { 0.2, 0.51 }, { 0.64, 0.55 } } })
hl.curve("notGill", { type = "bezier", points = { { 0.64, 0.11 }, { 0.92, 0.47 } } })
hl.curve("Gill", { type = "bezier", points = { { 0.08, 0.51 }, { 0.45, 0.92 } } })


-- MOTOR DE ANIMACIONES: Asignación (hl.animation)

hl.animation({ leaf = "global", enabled = true, speed = 2.73, bezier = "promontory" })

-- Capas
hl.animation({ leaf = "layersIn", enabled = true, speed = 3.96, bezier = "easePersonal", style = "slide" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 3.45, bezier = "partialLinear", style = "slide" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 2.79, bezier = "notGill" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 2.39, bezier = "Gill" })

-- Ventanas
hl.animation({ leaf = "windowsIn", enabled = true, speed = 2.45, bezier = "promontory" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 2.78, bezier = "promontory", style = "slide" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 2.43, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "border", enabled = true, speed = 4.49, bezier = "promontory" })

-- Workspaces
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 1.75, bezier = "easePersonal", style = "slide" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.75, bezier = "easePersonal", style = "slide" })
hl.animation({
    leaf = "specialWorkspaceIn",
    enabled = true,
    speed = 1.45,
    bezier = "partialLinear",
    style =
    "slide bottom"
})
hl.animation({ leaf = "specialWorkspaceOut", enabled = true, speed = 1.45, bezier = "easePersonal", style = "slide top" })
hl.animation({ leaf = "zoomFactor", enabled = true, speed = 7.0, bezier = "quick" })
