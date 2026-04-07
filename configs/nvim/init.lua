-- Configuración de apariencia
vim.opt.termguicolors = true   
vim.opt.number = true          
vim.opt.relativenumber = false 
vim.opt.cursorline = true      

-- Función de transparencia y COLORES DE NÚMEROS
local function setup_colors()
    local highlights = {
        "Normal", "NormalNC", "Folded", "NonText",
        "SpecialKey", "VertSplit", "SignColumn", "EndOfBuffer",
    }
    for _, name in ipairs(highlights) do
        vim.cmd(string.format("highlight %s guibg=none ctermbg=none", name))
    end

    -- FORZAR COLOR DE NÚMEROS (Para que se vean sobre el wallpaper)
    -- LineNr es el número normal, CursorLineNr es el de la línea actual
    vim.cmd([[
        highlight LineNr guifg=#50e3fe gui=bold
        highlight CursorLineNr guifg=#ffffff gui=bold
    ]])
end

setup_colors()
