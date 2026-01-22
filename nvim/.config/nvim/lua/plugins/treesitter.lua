return {
    'nvim-treesitter/nvim-treesitter',
    branch = 'master',
    build = ":TSUpdate",
    config = function()
        local configs = require("nvim-treesitter.configs")
        configs.setup({
            highlight = {
                enable = true,
            },
            indent = { enable = true },
            autotag = { enable = true },
            ensure_installed = {
                "lua",
                "bash",
                "css",
                "diff",
                "hyprlang",
                "json",
                "jsonc",
                "markdown",
                "vim",
                "toml",
                "html",
                "yaml",
            },
            auto_install = false,
        })
    end
}
