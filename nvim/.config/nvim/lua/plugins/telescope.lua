return {
    'nvim-telescope/telescope.nvim',
    version = '*',
    dependencies = {
        'nvim-lua/plenary.nvim',
        { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    },
    config = function()
        local builtin = require('telescope.builtin')

        vim.keymap.set('n', '<leader>ff', function()
            builtin.find_files({
                find_command = {
                    "rg",
                    "--files",
                    "--hidden",
                    "--glob", "!**/.git/*",
                    "--glob", "!**/.gitignore"
                }
            })
        end, { desc = 'Telescope find files' })

        vim.keymap.set('n', '<leader>fg', function()
            builtin.live_grep({
                additional_args = function()
                    return {
                        "--hidden",
                        "--glob", "!**/.git/*",
                        "--glob", "!**/.gitignore"
                    }
                end
            })
        end, { desc = 'Telescope live grep' })

        vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
        vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
    end
}
