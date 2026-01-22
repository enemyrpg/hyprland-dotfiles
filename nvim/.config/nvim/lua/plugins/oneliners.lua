return {
    { -- This helps with ssh tunneling and copying to clipboard
        'ojroques/vim-oscyank',
    },
    { -- Git plugin
        'tpope/vim-fugitive',
    },
    { -- Another Git plugin
        'lewis6991/gitsigns.nvim',
    },
    { -- Show CSS Colors
        'brenoprata10/nvim-highlight-colors',
        config = function()
            require('nvim-highlight-colors').setup({})
        end
    },
    { -- Show historical versions of the file locally
        'mbbill/undotree',
    },
    { -- Better comment support (gc / gb)
        'numToStr/Comment.nvim',
        opts = {},
    },
    { -- Automatically toggle between relative and absolute line numbers
        'sitiom/nvim-numbertoggle',
    },
}
