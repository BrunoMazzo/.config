-- Treesitter configuration
-- vim.pack version - no lazy loading

-- Add the plugin
vim.pack.add({"https://github.com/nvim-treesitter/nvim-treesitter.git"})

-- Configure the plugin
local treesitter = require("nvim-treesitter")

-- Install parsers
local parsers = {
  "bash",
  "c",
  "css",
  "diff",
  "go",
  "gotmpl",
  "html",
  "javascript",
  "jsdoc",
  "json",
  "jsx",
  "lua",
  "luadoc",
  "luap",
  "markdown",
  "markdown_inline",
  "printf",
  "python",
  "query",
  "regex",
  "toml",
  "tsx",
  "typescript",
  "swift",
  "vim",
  "vimdoc",
  "xml",
  "yaml",
}

-- Install parsers asynchronously
treesitter.install(parsers)

-- Register custom filetypes
vim.treesitter.language.register("gotmpl", { "gohtml", "gotmpl" })

-- Auto-start highlights & indentation
vim.api.nvim_create_autocmd("FileType", {
  desc = "User: enable treesitter highlighting",
  callback = function(ctx)
    -- highlights
    local hasStarted = pcall(vim.treesitter.start, ctx.buf)

    -- indent
    local dontUseTreesitterIndent = { "bash", "zsh", "markdown", "javascript" }
    if hasStarted and not vim.list_contains(dontUseTreesitterIndent, ctx.match) then
      vim.bo[ctx.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end,
})
