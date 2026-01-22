return {
    'goolord/alpha-nvim',
    config = function()
        local alpha = require('alpha')
        local dashboard = require("alpha.themes.dashboard")

        dashboard.section.header.val = {
            [[ ]],
            [[ ]],
            [[███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗]],
            [[████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║]],
            [[██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║]],
            [[██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║]],
            [[██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║]],
            [[╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝]],
            [[ ]],
        }

        dashboard.section.buttons.val = {
            dashboard.button("f", "󰍉  Find file",
                ":lua require('telescope.builtin').find_files({ find_command = { 'rg', '--files', '--hidden', '--glob', '!**/.git/*', '--glob', '!**/.gitignore' } })<CR>"),
            dashboard.button("g", "󰥩  Find in file (grep)",
                ":lua require('telescope.builtin').live_grep({ additional_args = function() return { '--hidden', '--glob', '!**/.git/*', '--glob', '!**/.gitignore' } end })<CR>"),
            dashboard.button("e", "  Browse files", ":Ex<CR>"),
            dashboard.button("d", "󰯂  Browse dotfiles", ":e ~/dotfiles/<CR>"),
            dashboard.button("c", "  Config", ":e ~/.config/nvim/<CR>"),
            dashboard.button("m", "  Keybinds", ":e ~/.config/nvim/lua/config/keybinds.lua<CR>"),
            dashboard.button("p", "  Plugins", ":Lazy<CR>"),
            dashboard.button("q", "󰅙  Quit", ":q!<CR>"),
        }

        dashboard.section.footer.val = function()
            return vim.g.startup_time_ms or "[[  ]]"
        end

        dashboard.section.buttons.opts.hl = "Keyword"
        dashboard.opts.opts.noautocmd = true
        alpha.setup(dashboard.opts)
    end
}
