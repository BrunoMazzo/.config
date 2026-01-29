-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

local function augroup(name)
  return vim.api.nvim_create_augroup("lazyvim_" .. name, { clear = true })
end

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("highlight_yank"),
  callback = function()
    (vim.hl or vim.highlight).on_yank()
  end,
})

-- close some filetypes with <q>
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("close_with_q"),
  pattern = {
    "PlenaryTestPopup",
    "checkhealth",
    "dbout",
    "gitsigns-blame",
    "grug-far",
    "help",
    "lspinfo",
    "neotest-output",
    "neotest-output-panel",
    "neotest-summary",
    "notify",
    "qf",
    "spectre_panel",
    "startuptime",
    "tsplayground",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.schedule(function()
      vim.keymap.set("n", "q", function()
        vim.cmd("close")
        pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
      end, {
        buffer = event.buf,
        silent = true,
        desc = "Quit buffer",
      })
    end)
  end,
})

-- wrap and check for spell in text filetypes
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("wrap_spell"),
  pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

-- Fix conceallevel for json files
vim.api.nvim_create_autocmd({ "FileType" }, {
  group = augroup("json_conceal"),
  pattern = { "json", "jsonc", "json5" },
  callback = function()
    vim.opt_local.conceallevel = 0
  end,
})

-- Detect gohtml files
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  group = augroup("gohtml_filetype"),
  pattern = { "*.gohtml", "*.gotmpl" },
  callback = function()
    vim.bo.filetype = "gotmpl"
  end,
})

-- Disable semantic tokens for gotmpl files
vim.api.nvim_create_autocmd("LspAttach", {
  group = augroup("disable_gotmpl_semantic"),
  callback = function(args)
    local bufnr = args.buf
    local client_id = args.data.client_id
    local client = vim.lsp.get_client_by_id(client_id)
    if vim.bo[bufnr].filetype == "gotmpl" and client then
      vim.lsp.semantic_tokens.stop(bufnr, client_id)
      -- Disable document highlight (references highlighting)
      client.server_capabilities.documentHighlightProvider = false
    end
  end,
})

-- Disable treesitter injection region highlighting
vim.api.nvim_create_autocmd("ColorScheme", {
  group = augroup("disable_injection_highlight"),
  callback = function()
    vim.api.nvim_set_hl(0, "@injection.content", {})
    vim.api.nvim_set_hl(0, "@text.literal", {})
    vim.api.nvim_set_hl(0, "TreesitterContext", {})
  end,
})
vim.api.nvim_set_hl(0, "@injection.content", {})
vim.api.nvim_set_hl(0, "@text.literal", {})
vim.api.nvim_set_hl(0, "TreesitterContext", {})

