return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    branch = "main",
    lazy = false,
    keys = {
      { "<c-space>", desc = "Increment Selection" },
      { "<bs>", desc = "Decrement Selection", mode = "x" },
    },
    config = function()
      local treesitter = require("nvim-treesitter")
      treesitter
        .install({
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
        })
        :wait(300000)

      -- vim.treesitter.language.register("tsx", { "typescriptreact" })
      vim.treesitter.language.register("gotmpl", { "gohtml", "gotmpl" })

      -- auto-start highlights & indentation
      vim.api.nvim_create_autocmd("FileType", {
        desc = "User: enable treesitter highlighting",
        callback = function(ctx)
          -- highlights
          local hasStarted = pcall(vim.treesitter.start, ctx.buf) -- errors for filetypes with no parser

          -- indent
          local dontUseTreesitterIndent = { "bash", "zsh", "markdown", "javascript" }
          if hasStarted and not vim.list_contains(dontUseTreesitterIndent, ctx.match) then
            vim.bo[ctx.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    event = "VeryLazy",
    enabled = false,
    config = function()
      -- When in diff mode, we want to use the default
      -- vim text objects c & C instead of the treesitter ones.
      local move = require("nvim-treesitter.textobjects.move") ---@type table<string,fun(...)>
      local configs = require("nvim-treesitter.configs")
      for name, fn in pairs(move) do
        if name:find("goto") == 1 then
          move[name] = function(q, ...)
            if vim.wo.diff then
              local config = configs.get_module("textobjects.move")[name] ---@type table<string,string>
              for key, query in pairs(config or {}) do
                if q == query and key:find("[%]%[][cC]") then
                  vim.cmd("normal! " .. key)
                  return
                end
              end
            end
            return fn(q, ...)
          end
        end
      end
    end,
  },
}
