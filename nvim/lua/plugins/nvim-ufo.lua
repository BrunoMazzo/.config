-- nvim-ufo configuration
-- vim.pack version - no lazy loading

-- Add dependency first
vim.pack.add({ "https://github.com/kevinhwang91/promise-async.git" })

-- Add the main plugin
vim.pack.add({ "https://github.com/kevinhwang91/nvim-ufo.git" })

-- Configure the plugin
require("ufo").setup({
  provider_selector = function(bufnr, filetype, buftype)
    return { "lsp", "indent" }
  end,
})

vim.keymap.set("n", "zR", require("ufo").openAllFolds)
vim.keymap.set("n", "zM", require("ufo").closeAllFolds)
