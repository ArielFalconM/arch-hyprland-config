---@diagnostic disable: undefined-global

-- Configuración de apariencia
vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true


local function setup_colors()
    local highlights = {
        "Normal", "NormalNC", "Folded", "NonText",
        "SpecialKey", "VertSplit", "SignColumn", "EndOfBuffer",
    }


    for _, name in ipairs(highlights) do
        vim.api.nvim_set_hl(0, name, { bg = "NONE", ctermbg = "NONE" })
    end


    vim.api.nvim_set_hl(0, "LineNr", { fg = "#50e3fe", bold = true })
    vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#ffffff", bold = true })
end

vim.cmd.colorscheme("zaibatsu")
setup_colors()


vim.api.nvim_create_autocmd("ColorScheme", {
    pattern = "*",
    callback = setup_colors,
})
