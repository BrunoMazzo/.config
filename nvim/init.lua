-- Neovim configuration using vim.pack (built-in package manager)
-- Requires Neovim 0.11+

-- Set leader keys early
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Bootstrap vim.pack
local packpath = vim.fn.stdpath("data") .. "/site/pack/packer"

-- Ensure the pack directory exists
vim.fn.mkdir(packpath .. "/start", "p")
vim.fn.mkdir(packpath .. "/opt", "p")

-- Load core configuration
require("config.options")
require("config.keymaps")
require("config.autocmds")

-- Load plugins using vim.pack
require("plugins")
