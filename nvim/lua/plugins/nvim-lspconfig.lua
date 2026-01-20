return {
  "neovim/nvim-lspconfig",
  config = function()
    vim.lsp.inlay_hint.enable(true)

    -- vim.lsp.enable("gopls")
    vim.lsp.config("gopls", {
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
    --
    -- Using Typescript tools for the LSP management
    vim.lsp.enable("tsgo")
    vim.lsp.enable("eslint")
    --
    -- lspconfig.sourcekit.setup({
    --   cmd = { vim.trim(vim.fn.system("xcrun -f sourcekit-lsp")), },
    --   capabilities = capabilities,
    --   on_init = function(client)
    --     -- HACK: to fix some issues with LSP
    --     -- more details: https://github.com/neovim/neovim/issues/19237#issuecomment-2237037154
    --     client.offset_encoding = "utf-8"
    --   end,
    -- })
    -- mason_lspconfig.setup_handlers({
    --   -- default handler for installed servers
    --   function(server_name)
    --     lspconfig[server_name].setup({
    --       capabilities = capabilities,
    --     })
    --   end,
    -- })

    local keymap = vim.keymap
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("UserLspConfig", {}),
      callback = function(ev)
        -- Buffer local mappings.
        -- See `:help vim.lsp.*` for documentation on any of the below functions
        local opts = { buffer = ev.buf, silent = true }

        -- set keybinds
        opts.desc = "Show LSP references"
        keymap.set("n", "gr", "<cmd>FzfLua lsp_references jump1=true ignore_current_line=true<cr>", opts) -- show definition, references

        opts.desc = "Go to declaration"
        keymap.set("n", "gD", "<cmd>FzfLua lsp_declarations jump1=true<cr>", opts) -- go to declaration

        opts.desc = "Show LSP definitions"
        keymap.set("n", "gd", "<cmd>FzfLua lsp_definitions jump1=true ignore_current_line=true<cr>", opts) -- show lsp definitions

        opts.desc = "Show LSP implementations"
        keymap.set("n", "gi", "<cmd>FzfLua lsp_implementations jump1=true ignore_current_line=true<cr>", opts) -- show lsp implementations

        opts.desc = "Show LSP type definitions"
        keymap.set("n", "gy", "<cmd>FzfLua lsp_typedefs jump1=true ignore_current_line=true<cr>", opts) -- show lsp type definitions

        opts.desc = "See available code actions"
        keymap.set({ "n", "v" }, "<leader>ca", "<cmd>FzfLua lsp_code_actions<cr>", opts) -- see available code actions, in visual mode will apply to selection

        opts.desc = "Smart rename"
        keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts) -- smart rename

        opts.desc = "Show line diagnostics"
        keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts) -- show diagnostics for line

        opts.desc = "Go to previous diagnostic"
        keymap.set("n", "[d", function()
          vim.diagnostic.jump({ count = -1, float = true })
        end, opts) -- jump to previous diagnostic in buffer

        opts.desc = "Go to next diagnostic"
        keymap.set("n", "]d", function()
          vim.diagnostic.jump({ count = 1, float = true })
        end, opts) -- jump to next diagnostic in buffer

        opts.desc = "Show documentation for what is under cursor"
        keymap.set("n", "K", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

        opts.desc = "Restart LSP"
        keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessary
      end,
    })

    vim.api.nvim_create_autocmd("LspAttach", {
      pattern = { "*.ts", "*.tsx" },
      group = vim.api.nvim_create_augroup("UserLspConfig-ts_ls", {}),
      callback = function(ev)
        -- Buffer local mappings.
        -- See `:help vim.lsp.*` for documentation on any of the below functions
        local opts = { buffer = ev.buf, silent = true }

        -- set keybinds
        opts.desc = "Organize imports"
        keymap.set("n", "<leader>co", "<cmd>TSToolsOrganizeImports sync<cr>", opts)

        opts.desc = "Fix all imports"
        keymap.set("n", "<leader>cI", "<cmd>TSToolsAddMissingImports sync<cr><cmd>TSToolsRemoveUnused sync<cr>", opts)

        opts.desc = "Add missing imports"
        keymap.set("n", "<leader>ci", "<cmd>TSToolsAddMissingImports sync<cr>", opts)

        opts.desc = "Fix all"
        keymap.set("n", "<leader>cF", "<cmd>LspEslintFixAll<cr>", opts)

        -- Autocmd to fix ESLint errors on save
        vim.api.nvim_create_autocmd("BufWritePre", {
          buffer = ev.buf,
          command = "LspEslintFixAll", -- Or a similar command provided by your ESLint LSP setup
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
  end,
}
