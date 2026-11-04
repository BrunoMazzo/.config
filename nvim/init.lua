-- Neovim configuration using vim.pack (built-in package manager)
-- Requires Neovim 0.11+

-- Set leader keys early
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Load core configuration
require("config.options")
require("config.keymaps")
require("config.autocmds")

-- Load plugins using vim.pack
require("plugins")
