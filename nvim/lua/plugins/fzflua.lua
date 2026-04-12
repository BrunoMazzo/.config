-- Fzf-lua configuration
-- vim.pack version - no lazy loading

-- Add the plugin
vim.pack.add({"https://github.com/ibhagwan/fzf-lua.git"})

-- Setup fzf-lua
require("fzf-lua").setup({
  -- Use default setup with some customizations
  winopts = {
    height = 0.85,
    width = 0.80,
    preview = {
      default = "bat",
      horizontal = "right:50%",
    },
  },
  keymap = {
    fzf = {
      ["ctrl-j"] = "down",
      ["ctrl-k"] = "up",
    },
  },
})

-- Fzf-specific terminal mappings
vim.api.nvim_create_autocmd("FileType", {
  pattern = "fzf",
  callback = function()
    vim.keymap.set("t", "<c-j>", "<c-j>", { buffer = true, nowait = true })
    vim.keymap.set("t", "<c-k>", "<c-k>", { buffer = true, nowait = true })
  end,
})

-- Keymaps
vim.keymap.set("n", "<leader>,", "<cmd>FzfLua buffers sort_mru=true sort_lastused=true<cr>", { desc = "Switch Buffer" })
vim.keymap.set("n", "<leader>/", "<cmd>FzfLua live_grep<cr>", { desc = "Grep (Root Dir)" })
vim.keymap.set("n", "<leader>:", "<cmd>FzfLua command_history<cr>", { desc = "Command History" })
vim.keymap.set("n", "<leader><space>", "<cmd>FzfLua files<cr>", { desc = "Find Files (Root Dir)" })

-- Find
vim.keymap.set("n", "<leader>fb", "<cmd>FzfLua buffers sort_mru=true sort_lastused=true<cr>", { desc = "Buffers" })
vim.keymap.set("n", "<leader>fc", "<cmd>FzfLua files cwd=" .. vim.fn.stdpath("config") .. "<cr>", { desc = "Find Config File" })
vim.keymap.set("n", "<leader>ff", "<cmd>FzfLua files<cr>", { desc = "Find Files (Root Dir)" })
vim.keymap.set("n", "<leader>fg", "<cmd>FzfLua git_files<cr>", { desc = "Find Files (git-files)" })
vim.keymap.set("n", "<leader>fr", "<cmd>FzfLua oldfiles<cr>", { desc = "Recent" })

-- Git
vim.keymap.set("n", "<leader>gc", "<cmd>FzfLua git_commits<CR>", { desc = "Commits" })
vim.keymap.set("n", "<leader>gs", "<cmd>FzfLua git_status<CR>", { desc = "Status" })

-- Search
vim.keymap.set("n", '<leader>s"', "<cmd>FzfLua registers<cr>", { desc = "Registers" })
vim.keymap.set("n", "<leader>sa", "<cmd>FzfLua autocmds<cr>", { desc = "Auto Commands" })
vim.keymap.set("n", "<leader>sb", "<cmd>FzfLua grep_curbuf<cr>", { desc = "Buffer" })
vim.keymap.set("n", "<leader>sc", "<cmd>FzfLua command_history<cr>", { desc = "Command History" })
vim.keymap.set("n", "<leader>sC", "<cmd>FzfLua commands<cr>", { desc = "Commands" })
vim.keymap.set("n", "<leader>sd", "<cmd>FzfLua diagnostics_document<cr>", { desc = "Document Diagnostics" })
vim.keymap.set("n", "<leader>sD", "<cmd>FzfLua diagnostics_workspace<cr>", { desc = "Workspace Diagnostics" })
vim.keymap.set("n", "<leader>sg", "<cmd>FzfLua live_grep<cr>", { desc = "Grep (Root Dir)" })
vim.keymap.set("n", "<leader>sh", "<cmd>FzfLua help_tags<cr>", { desc = "Help Pages" })
vim.keymap.set("n", "<leader>sH", "<cmd>FzfLua highlights<cr>", { desc = "Search Highlight Groups" })
vim.keymap.set("n", "<leader>sj", "<cmd>FzfLua jumps<cr>", { desc = "Jumplist" })
vim.keymap.set("n", "<leader>sk", "<cmd>FzfLua keymaps<cr>", { desc = "Key Maps" })
vim.keymap.set("n", "<leader>sl", "<cmd>FzfLua loclist<cr>", { desc = "Location List" })
vim.keymap.set("n", "<leader>sM", "<cmd>FzfLua man_pages<cr>", { desc = "Man Pages" })
vim.keymap.set("n", "<leader>sm", "<cmd>FzfLua marks<cr>", { desc = "Jump to Mark" })
vim.keymap.set("n", "<leader>sR", "<cmd>FzfLua resume<cr>", { desc = "Resume" })
vim.keymap.set("n", "<leader>sq", "<cmd>FzfLua quickfix<cr>", { desc = "Quickfix List" })
vim.keymap.set("n", "<leader>sw", "<cmd>FzfLua grep_cword<cr>", { desc = "Word (Root Dir)" })
vim.keymap.set("v", "<leader>sw", "<cmd>FzfLua grep_visual<cr>", { desc = "Selection (Root Dir)" })
vim.keymap.set("n", "<leader>uC", "<cmd>FzfLua colorschemes<cr>", { desc = "Colorscheme with Preview" })
