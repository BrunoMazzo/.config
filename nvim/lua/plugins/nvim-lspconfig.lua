-- nvim-lspconfig configuration
-- vim.pack version - no lazy loading

-- Add the plugin
vim.pack.add({ "https://github.com/neovim/nvim-lspconfig.git" })

-- Enable inlay hints
vim.lsp.inlay_hint.enable(true)

-- Get blink.cmp capabilities
local capabilities = nil
local ok, blink = pcall(require, "blink.cmp")
if ok then
  capabilities = blink.get_lsp_capabilities()
end

-- Configure LSP servers
vim.lsp.config("tsgo", {
  capabilities = capabilities,
})
vim.lsp.enable("tsgo")

vim.lsp.config("eslint", {
  capabilities = capabilities,
})
vim.lsp.enable("eslint")

-- Gopls configuration
vim.lsp.config("gopls", {
  capabilities = capabilities,
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  settings = {
    gopls = {
      buildFlags = { "-tags=integration" },
      analyses = {
        unusedparams = true,
        unusedwrite = true,
        shadow = true,
      },
      staticcheck = true,
      hints = {
        rangeVariableTypes = true,
        parameterNames = true,
        constantValues = true,
        assignVariableTypes = true,
        compositeLiteralFields = true,
        compositeLiteralTypes = true,
        functionTypeParameters = true,
      },
    },
  },
})
vim.lsp.enable("gopls")

-- HTML configuration
vim.lsp.config("html", {
  capabilities = capabilities,
  filetypes = { "html", "gotmpl" },
})

vim.lsp.enable("lua")

-- LSP attach keymaps
local keymap = vim.keymap
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    local opts = { buffer = ev.buf, silent = true }

    opts.desc = "Show LSP references"
    keymap.set("n", "gr", "<cmd>FzfLua lsp_references jump1=true ignore_current_line=true<cr>", opts)

    opts.desc = "Go to declaration"
    keymap.set("n", "gD", "<cmd>FzfLua lsp_declarations jump1=true<cr>", opts)

    opts.desc = "Show LSP definitions"
    keymap.set("n", "gd", "<cmd>FzfLua lsp_definitions jump1=true ignore_current_line=true<cr>", opts)

    opts.desc = "Show LSP implementations"
    keymap.set("n", "gi", "<cmd>FzfLua lsp_implementations jump1=true ignore_current_line=true<cr>", opts)

    opts.desc = "Show LSP type definitions"
    keymap.set("n", "gy", "<cmd>FzfLua lsp_typedefs jump1=true ignore_current_line=true<cr>", opts)

    opts.desc = "See available code actions"
    keymap.set({ "n", "v" }, "<leader>ca", "<cmd>FzfLua lsp_code_actions<cr>", opts)

    opts.desc = "Smart rename"
    keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

    opts.desc = "Show line diagnostics"
    keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)

    opts.desc = "Go to previous diagnostic"
    keymap.set("n", "[d", function()
      vim.diagnostic.jump({ count = -1, float = true })
    end, opts)

    opts.desc = "Go to next diagnostic"
    keymap.set("n", "]d", function()
      vim.diagnostic.jump({ count = 1, float = true })
    end, opts)

    opts.desc = "Show documentation for what is under cursor"
    keymap.set("n", "K", vim.lsp.buf.hover, opts)

    opts.desc = "Restart LSP"
    keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts)
  end,
})

-- TypeScript specific keymaps
vim.api.nvim_create_autocmd("LspAttach", {
  pattern = { "*.ts", "*.tsx" },
  group = vim.api.nvim_create_augroup("UserLspConfig-ts_ls", {}),
  callback = function(ev)
    local opts = { buffer = ev.buf, silent = true }

    opts.desc = "Organize imports"
    keymap.set("n", "<leader>co", function()
      vim.lsp.buf.code_action({
        context = {
          only = { "source.organizeImports" },
        },
        apply = true,
      })
    end, opts)

    opts.desc = "Fix all imports"
    keymap.set("n", "<leader>cI", function()
      vim.lsp.buf.code_action({
        context = {
          only = { "source.addMissingImports.ts" },
        },
        apply = true,
      })
      vim.lsp.buf.code_action({
        context = {
          only = { "source.removeUnusedImports.ts" },
        },
        apply = true,
      })
    end, opts)

    opts.desc = "Add missing imports"
    keymap.set("n", "<leader>ci", function()
      vim.lsp.buf.code_action({
        context = {
          only = { "source.addMissingImports.ts" },
        },
        apply = true,
      })
    end, opts)

    opts.desc = "Fix all"
    keymap.set("n", "<leader>cF", "<cmd>LspEslintFixAll<cr>", opts)

    -- Autocmd to fix ESLint errors on save
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = ev.buf,
      command = "LspEslintFixAll",
    })
  end,
})

-- Go auto import
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.go",
  callback = function()
    vim.cmd("GoImports")
    vim.lsp.buf.format({ async = false })
  end,
})
