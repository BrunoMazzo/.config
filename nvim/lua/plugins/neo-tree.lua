-- Neo-tree configuration
-- vim.pack version - no lazy loading

-- Add dependencies first
vim.pack.add({ "https://github.com/nvim-lua/plenary.nvim.git" })
vim.pack.add({ "https://github.com/MunifTanjim/nui.nvim.git" })
vim.pack.add({ "https://github.com/nvim-tree/nvim-web-devicons.git" })

-- Add neo-tree with version pin
vim.pack.add({
  {
    src = "https://github.com/nvim-neo-tree/neo-tree.nvim",
    version = vim.version.range("3"),
  },
})

-- Configure the plugin
require("neo-tree").setup({
  sources = { "filesystem", "buffers", "git_status" },
  open_files_do_not_replace_types = { "terminal", "Trouble", "trouble", "qf", "Outline" },
  filesystem = {
    bind_to_cwd = false,
    follow_current_file = { enabled = true },
    use_libuv_file_watcher = true,
    filtered_items = {
      hide_hidden = false,
    },
  },
  window = {
    position = "right",
    width = 30,
    mappings = {
      ["l"] = "open",
      ["h"] = "close_node",
      ["<space>"] = "none",
    },
  },
  default_component_configs = {
    indent = {
      with_expanders = true,
      expander_highlight = "NeoTreeExpander",
    },
  },
  event_handlers = {
    {
      event = "file_opened",
      handler = function(file_path)
        -- auto close
        require("neo-tree.command").execute({ action = "close" })
      end,
    },
  },
})

-- Keymaps
vim.keymap.set("n", "<leader>fe", "<cmd>Neotree toggle position=right<cr>", { desc = "Explorer NeoTree (cwd)" })
vim.keymap.set("n", "<leader>e", "<cmd>Neotree toggle position=right<cr>", { desc = "Explorer NeoTree (Root Dir)" })
vim.keymap.set("n", "<leader>ge", "<cmd>Neotree git_status toggle position=right<cr>", { desc = "Git Explorer" })
vim.keymap.set("n", "<leader>be", "<cmd>Neotree buffers toggle position=right<cr>", { desc = "Buffer Explorer" })
