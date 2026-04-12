-- Plugin management using vim.pack (Neovim 0.11+ built-in package manager)
-- Each plugin file in this directory handles its own vim.pack.add() and configuration

local M = {}

-- Scan the plugins directory and load each plugin file
local plugins_dir = vim.fn.stdpath("config") .. "/lua/plugins"
local scan = vim.uv.fs_scandir(plugins_dir)

if scan then
  while true do
    local name, type = vim.uv.fs_scandir_next(scan)
    if not name then
      break
    end

    -- Skip init.lua and non-lua files
    if name ~= "init.lua" and name:match("%.lua$") and type == "file" then
      local module_name = "plugins." .. name:gsub("%.lua$", "")

      -- Load each plugin module (each handles its own vim.pack.add + config)
      local ok, err = pcall(require, module_name)
      if not ok then
        vim.notify("Failed to load plugin: " .. module_name .. "\n" .. err, vim.log.levels.WARN)
      end
    end
  end
end

-- Set colorscheme after all plugins are loaded
-- Use pcall to handle case where colorscheme isn't available yet
local theme_ok, _ = pcall(vim.cmd, "colorscheme catppuccin-mocha")
if not theme_ok then
  -- Fall back to built-in colorscheme
  vim.cmd("colorscheme habamax")
end

return M
