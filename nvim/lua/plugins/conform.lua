-- Conform configuration
-- vim.pack version - no lazy loading

-- Add the plugin
vim.pack.add({"https://github.com/stevearc/conform.nvim.git"})

-- Configure the plugin
require("conform").setup({
  formatters_by_ft = {
    go = { "gofmt" },
    javascript = { "prettier" },
    typescript = { "prettier" },
    javascriptreact = { "prettier" },
    typescriptreact = { "prettier" },
    svelte = { "prettier" },
    css = { "prettier" },
    html = { "prettier" },
    json = { "prettier" },
    yaml = { "prettier" },
    markdown = { "prettier" },
    graphql = { "prettier" },
    liquid = { "prettier" },
    lua = { "stylua" },
    python = { "isort", "black" },
    swift = { "swiftformat" },
  },
  format_on_save = {
    lsp_fallback = true,
    async = false,
    timeout_ms = 1000,
  },
})

-- Keymaps
vim.keymap.set({ "n", "v" }, "<leader>cf", function()
  require("conform").format({ async = true })
end, { desc = "Format Injected Langs" })
