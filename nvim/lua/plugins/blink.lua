-- Blink.cmp configuration
-- vim.pack version - no lazy loading

-- Add the plugin with version pin
vim.pack.add({
  {
    src = "https://github.com/saghen/blink.cmp",
    version = vim.version.range("1"),
  },
})
-- Configure the plugin
require("blink.cmp").setup({
  fuzzy = {
    implementation = "lua",
  },

  -- Keymap configuration
  keymap = {
    preset = "default",
    ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
    ["<C-e>"] = { "hide" },
    ["<C-y>"] = { "select_and_accept" },
    ["<C-p>"] = { "select_prev", "fallback" },
    ["<C-n>"] = { "select_next", "fallback" },
    ["<C-b>"] = { "scroll_documentation_up", "fallback" },
    ["<C-f>"] = { "scroll_documentation_down", "fallback" },
    ["<Tab>"] = { "snippet_forward", "fallback" },
    ["<S-Tab>"] = { "snippet_backward", "fallback" },
  },

  completion = {
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 500,
    },
    menu = {
      draw = {
        columns = { { "label", "label_description", gap = 1 }, { "kind_icon", "kind" }, { "source_name" } },
      },
    },
  },

  signature = {
    enabled = true,
  },

  sources = {
    default = { "lsp", "path", "snippets", "buffer" },
    providers = {
      lsp = {
        name = "LSP",
        module = "blink.cmp.sources.lsp",
        fallbacks = { "buffer" },
      },
      path = {
        name = "Path",
        module = "blink.cmp.sources.path",
      },
      snippets = {
        name = "Snippets",
        module = "blink.cmp.sources.snippets",
      },
      buffer = {
        name = "Buffer",
        module = "blink.cmp.sources.buffer",
      },
    },
  },

  -- Enable for all filetypes
  enabled = function()
    return true
  end,
})
