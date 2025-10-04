-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- Enable word wrap
vim.opt.wrap = true

-- Optional: break lines at word boundaries (don't break words in middle)
vim.opt.linebreak = true

-- Optional: show wrapped lines with an indicator
vim.opt.breakindent = true
vim.opt.showbreak = "↪ "

vim.opt.number = true        -- Line numbers
vim.opt.relativenumber = true -- Relative line numbers

