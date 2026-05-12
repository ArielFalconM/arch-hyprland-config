-- Configuración de apariencia
---@diagnostic disable: undefined-global

vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.cursorline = true

-- Función de transparencia y colores de numeros
local function setup_colors()
    local highlights = {
        "Normal", "NormalNC", "Folded", "NonText",
        "SpecialKey", "VertSplit", "SignColumn", "EndOfBuffer",
    }
    for _, name in ipairs(highlights) do
        vim.cmd(string.format("highlight %s guibg=none ctermbg=none", name))
    end

    -- forzar colores de numeros
    vim.cmd([[
        highlight LineNr guifg=#50e3fe gui=bold
        highlight CursorLineNr guifg=#ffffff gui=bold
    ]])
end

setup_colors()
