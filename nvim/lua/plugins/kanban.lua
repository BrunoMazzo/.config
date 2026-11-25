-- Local Kanban board for the file-based ticket system.
-- Reads .scratch/<effort>/issues/*.md and shows a status board inside Neovim.
-- Pure Neovim API, no external plugin to install.

local kanban = require("kanban")

kanban.setup({
  -- Walk up from the cwd looking for .scratch first; this is the fallback
  -- when nvim is opened outside the project.
  fallback_root = "/Users/brunomazzo/Documents/OpenSource/ReaderTracker/.scratch",
})

vim.keymap.set("n", "<leader>k", function()
  kanban.toggle()
end, { desc = "Kanban board (local tickets)" })

vim.api.nvim_create_user_command("Kanban", function(cmd)
  local opts = {}
  if cmd.args and cmd.args ~= "" then
    opts.root = vim.fn.fnamemodify(cmd.args, ":p")
  end
  kanban.open(opts)
end, {
  nargs = "?",
  complete = "dir",
  desc = "Open the local ticket Kanban board (optional: path to .scratch)",
})
