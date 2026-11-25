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
  -- Nest test/spec files under the source file they belong to.
  -- %1 is the source's base name and %2 its extension, so app.ts owns
  -- app.test.ts as well as app.integration.test.ts, app.feature.test.ts
  -- and any other qualified variant.
  nesting_rules = {
    tests = {
      pattern = "^(.+)%.([^.]+)$",
      files = {
        "%1.test.%2",
        "%1.spec.%2",
        "%1.*.test.%2",
        "%1.*.spec.%2",
      },
    },
  },
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
      -- A file with nested files expands on `l`; pressing `l` again opens it.
      ["l"] = { "open", config = { expand_nested_files = true } },
      ["h"] = "close_node",
      ["<space>"] = "toggle_node",
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
