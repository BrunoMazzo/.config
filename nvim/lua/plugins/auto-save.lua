-- auto-save configuration
-- vim.pack version - no lazy loading

-- Add the plugin
vim.pack.add({"https://github.com/pocco81/auto-save.nvim.git"})

-- Configure the plugin
require("auto-save").setup({
  enabled = true,
  debounce_delay = 1500,
  noautocmd = false,
  condition = function(buf)
    -- Check if buffer is valid
    if not vim.api.nvim_buf_is_valid(buf) then
      return false
    end

    -- Check if buffer is loaded
    if not vim.api.nvim_buf_is_loaded(buf) then
      return false
    end

    -- Exclude claudecode diff buffers by buffer name patterns
    local ok, bufname = pcall(vim.api.nvim_buf_get_name, buf)
    if not ok or not bufname then
      return false
    end

    if bufname:match("%(proposed%)") or bufname:match("%(NEW FILE %- proposed%)") or bufname:match("%(New%)") then
      return false
    end

    -- Exclude by buffer variables (claudecode sets these)
    if
      vim.b[buf].claudecode_diff_tab_name
      or vim.b[buf].claudecode_diff_new_win
      or vim.b[buf].claudecode_diff_target_win
    then
      return false
    end

    -- Exclude by buffer type (claudecode diff buffers use "acwrite")
    local buftype = vim.fn.getbufvar(buf, "&buftype")
    if buftype == "acwrite" then
      return false
    end

    return true -- Safe to auto-save
  end,
})
