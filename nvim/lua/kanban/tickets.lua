-- Filesystem layer for the local Kanban board.
--
-- The tickets are Wayfinder / Matt-Pocock-style markdown files:
--   .scratch/<effort>/issues/NN-slug.md
-- Each file carries its triage state on a `Status:` line near the top.

local M = {}

-- `Status: resolved` and the bold `**Status:** resolved` form both occur in
-- the wild (the to-tickets template uses the bold one).
local function status_value(line)
  return line:match("^Status:%s*(.*)$") or line:match("^%*%*Status:%*%*%s*(.*)$")
end

local function status_prefix(line)
  return line:match("^(%*%*Status:%*%*%s*)") or line:match("^(Status:%s*)")
end

--- Parse the header fields of a single ticket file.
---@param path string
---@return table|nil
function M.parse(path)
  local ok, lines = pcall(vim.fn.readfile, path, "", 60)
  if not ok or type(lines) ~= "table" then
    return nil
  end

  local fname = vim.fn.fnamemodify(path, ":t")
  local num = tonumber(fname:match("^(%d+)")) or 0
  local effort = vim.fn.fnamemodify(path, ":h:h:t")

  -- Fall back to a title derived from the filename.
  local title = fname:gsub("%.md$", ""):gsub("^%d+%-", ""):gsub("%-", " ")
  local seen_title = false
  local status_raw, type_raw, blocked_by

  for _, line in ipairs(lines) do
    if not seen_title then
      local heading = line:match("^#%s+(.+)$")
      if heading then
        -- "# 01 — Feed contract" -> "Feed contract"
        local cleaned = heading:gsub("^%d+%s*[^%a]*", "")
        if cleaned ~= "" then
          title = vim.trim(cleaned)
        end
        seen_title = true
      end
    end
    if not status_raw then
      local value = status_value(line)
      if value ~= nil then
        status_raw = vim.trim(value)
      end
    end
    if not type_raw then
      type_raw = line:match("^Type:%s*(.+)$")
    end
    if not blocked_by then
      blocked_by = line:match("^Blocked by:%s*(.+)$")
    end
  end

  return {
    path = vim.fn.fnamemodify(path, ":p"),
    effort = effort,
    num = num,
    title = title,
    status_raw = status_raw or "open",
    type = type_raw and vim.trim(type_raw) or "",
    blocked_by = blocked_by and vim.trim(blocked_by) or nil,
  }
end

--- Scan every ticket below a `.scratch` root.
---@param root string absolute path to the .scratch directory
---@return table[] tickets
function M.scan(root)
  local paths = vim.fn.glob(root .. "/*/issues/*.md", false, true)
  local out = {}
  for _, path in ipairs(paths or {}) do
    local ticket = M.parse(path)
    if ticket then
      out[#out + 1] = ticket
    end
  end
  table.sort(out, function(a, b)
    if a.effort ~= b.effort then
      return a.effort < b.effort
    end
    if a.num ~= b.num then
      return a.num < b.num
    end
    return a.path < b.path
  end)
  return out
end

--- Distinct effort names, sorted — used by the filter picker.
---@param tickets table[]
---@return string[]
function M.efforts(tickets)
  local seen, out = {}, {}
  for _, ticket in ipairs(tickets) do
    if not seen[ticket.effort] then
      seen[ticket.effort] = true
      out[#out + 1] = ticket.effort
    end
  end
  table.sort(out)
  return out
end

--- Rewrite a ticket's `Status:` line, leaving the rest of the file untouched.
--- Refuses to clobber a file that is open with unsaved changes, and reloads
--- any open (unmodified) buffers so edits stay in sync.
---@param path string
---@param value string the new canonical status value
---@return boolean ok
---@return string? err
function M.write_status(path, value)
  local open_bufs = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.api.nvim_buf_get_name(buf) == path then
      if vim.bo[buf].modified then
        return false, "ticket is open with unsaved changes — save or discard them first"
      end
      open_bufs[#open_bufs + 1] = buf
    end
  end

  local ok_read, lines = pcall(vim.fn.readfile, path)
  if not ok_read or type(lines) ~= "table" then
    return false, "cannot read " .. path
  end

  local replaced = false
  for i, line in ipairs(lines) do
    if not replaced and status_value(line) ~= nil then
      lines[i] = (status_prefix(line) or "Status: ") .. value
      replaced = true
    end
  end
  if not replaced then
    -- No Status line at all: add one just under the title.
    table.insert(lines, 2, "Status: " .. value)
  end

  local ok_write = pcall(vim.fn.writefile, lines, path)
  if not ok_write then
    return false, "cannot write " .. path
  end

  for _, buf in ipairs(open_bufs) do
    pcall(vim.api.nvim_buf_call, buf, function()
      vim.cmd("silent! edit!")
    end)
  end
  return true
end

return M
