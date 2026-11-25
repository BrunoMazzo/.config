-- Local Kanban board for file-based tickets.
--
-- Reads .scratch/<effort>/issues/NN-slug.md, groups every file by its
-- `Status:` line into columns, and opens a full-screen tab with one vertical
-- window per column. Each column is its own buffer: titles are never truncated,
-- they simply wrap with 'linebreak'. Cards can be moved between columns (which
-- rewrites the Status line) and opened as real files so every other plugin
-- keeps working on them.
--
-- Pure Neovim API, no external plugins. Requires Neovim 0.11+.

local tickets = require("kanban.tickets")

local M = {}

local ns_hl = vim.api.nvim_create_namespace("kanban_hl")

-- id        internal column key
-- title     label shown in the column winbar
-- status    value written back to `Status:` when a card lands here
-- fg        card colour (catppuccin-ish, readable on dark themes)
local DEFAULT_COLUMNS = {
  { id = "open", title = "Open / Backlog", status = "open", fg = "#89b4fa" },
  { id = "ready", title = "Ready", status = "ready-for-agent", fg = "#f9e2af" },
  { id = "claimed", title = "In Progress", status = "claimed", fg = "#fab387" },
  { id = "resolved", title = "Done", status = "resolved", fg = "#a6e3a1" },
  { id = "closed", title = "Closed", status = "closed", fg = "#9399b2" },
}

local defaults = {
  columns = DEFAULT_COLUMNS,
  -- Used when no .scratch is found by walking up from the cwd.
  fallback_root = nil,
}

local cfg = vim.deepcopy(defaults)
local state = nil

--- Override defaults. Call once from your plugin config.
---@param opts table|nil
function M.setup(opts)
  cfg = vim.tbl_deep_extend("force", vim.deepcopy(defaults), opts or {})
end

--- Map the messy real-world status strings onto one of the column ids.
local function normalize(raw)
  local s = vim.trim(raw or ""):lower()
  if s:match("^resolved") or s:match("^done") or s:match("^%*%*complete") or s:match("^complete") then
    return "resolved"
  end
  if
    s:match("^closed")
    or s:match("^abandoned")
    or s:match("^%*%*abandoned")
    or s:match("^wontfix")
    or s:match("^folded")
  then
    return "closed"
  end
  if
    s:match("^claimed")
    or s:match("^in%-progress")
    or s:match("^in progress")
    or s:match("^wip")
    or s:match("^doing")
  then
    return "claimed"
  end
  if s:match("^ready") then
    return "ready"
  end
  -- open / pending / needs-triage / captured / anything unknown
  return "open"
end

--- Find the ticket root: explicit arg > vim.g.kanban_root > walk up from cwd > fallback.
local function resolve_root(override)
  local candidate = override or vim.g.kanban_root
  if candidate then
    local abs = vim.fn.fnamemodify(candidate, ":p")
    return (abs:gsub("/+$", ""))
  end

  local dir = vim.fn.getcwd()
  for _ = 1, 8 do
    local scratch = dir .. "/.scratch"
    if vim.fn.isdirectory(scratch) == 1 then
      return scratch
    end
    local parent = vim.fn.fnamemodify(dir, ":h")
    if parent == dir then
      break
    end
    dir = parent
  end
  return cfg.fallback_root
end

-- Highlight groups are created at open() time, not at load time: the
-- colorscheme is applied last in plugins/init.lua and would clear them.
local function ensure_highlights()
  for _, col in ipairs(cfg.columns) do
    vim.api.nvim_set_hl(0, "Kanban_" .. col.id, { fg = col.fg })
    vim.api.nvim_set_hl(0, "KanbanHead_" .. col.id, { fg = col.fg, bold = true })
  end
end

local function buckets_for(state)
  local buckets = {}
  for _, col in ipairs(state.columns) do
    buckets[col.id] = {}
  end
  for _, ticket in ipairs(state.tickets) do
    if not state.filter or ticket.effort == state.filter then
      local id = normalize(ticket.status_raw)
      if not buckets[id] then
        id = "open"
      end
      table.insert(buckets[id], ticket)
    end
  end
  for _, list in pairs(buckets) do
    table.sort(list, function(a, b)
      if a.effort ~= b.effort then
        return a.effort < b.effort
      end
      if a.num ~= b.num then
        return a.num < b.num
      end
      return a.path < b.path
    end)
  end
  return buckets
end

--- Render one column buffer. Titles are written in full — 'wrap' + 'linebreak'
--- in the window display them without ever cutting text off.
local function render_column(state, c)
  local col = state.columns[c]
  local buf = state.bufs[c]
  local win = state.wins[c]
  local list = state.buckets[col.id]

  local lines, row_start = {}, {}
  for r, ticket in ipairs(list) do
    row_start[r] = #lines + 1
    local number = ticket.num > 0 and string.format("%02d", ticket.num) or "--"
    -- No truncation: the whole title goes in, wrapping is handled by the window.
    lines[#lines + 1] = (" %s  %s"):format(number, ticket.title)
    lines[#lines + 1] = ("     %s / %s"):format(ticket.effort, ticket.type ~= "" and ticket.type or "-")
  end
  if #lines == 0 then
    lines[1] = "  (no tickets)"
  end
  state.row_start[c] = row_start

  local old_lnum = vim.api.nvim_win_get_cursor(win)[1]
  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false

  vim.api.nvim_buf_clear_namespace(buf, ns_hl, 0, -1)
  if #list == 0 then
    vim.api.nvim_buf_add_highlight(buf, ns_hl, "Comment", 0, 0, -1)
  else
    for r in ipairs(list) do
      local row0 = row_start[r] - 1
      vim.api.nvim_buf_add_highlight(buf, ns_hl, "Kanban_" .. col.id, row0, 0, -1)
      vim.api.nvim_buf_add_highlight(buf, ns_hl, "Comment", row0 + 1, 0, -1)
    end
  end

  -- A persistent column header (and key hint) that stays while scrolling.
  vim.wo[win].winbar = ("%%#KanbanHead_%s#  %s  (%d) %%=%%#Comment# ? help   q close "):format(col.id, col.title, #list)

  vim.api.nvim_win_set_cursor(win, { math.max(1, math.min(old_lnum, #lines)), 0 })
end

--- Rebuild every column buffer from the current tickets.
local function render(state, opts)
  if not vim.api.nvim_tabpage_is_valid(state.tabpage) then
    return
  end
  opts = opts or {}
  state.buckets = buckets_for(state)
  for c = 1, #state.columns do
    render_column(state, c)
  end

  if opts.focus_path then
    for c, col in ipairs(state.columns) do
      for r, ticket in ipairs(state.buckets[col.id]) do
        if ticket.path == opts.focus_path then
          vim.api.nvim_set_current_win(state.wins[c])
          vim.api.nvim_win_set_cursor(state.wins[c], { state.row_start[c][r], 0 })
          state.focus_path = opts.focus_path
          return
        end
      end
    end
  end

  -- Default: first card of the first non-empty column.
  for c, col in ipairs(state.columns) do
    if #state.buckets[col.id] > 0 then
      vim.api.nvim_set_current_win(state.wins[c])
      vim.api.nvim_win_set_cursor(state.wins[c], { state.row_start[c][1], 0 })
      break
    end
  end
  state.focus_path = opts.focus_path
end

--- Ticket under the cursor in whichever column window is current.
local function card_at_cursor(state)
  local win = vim.api.nvim_get_current_win()
  local c = state.col_of_win[win]
  if not c then
    return nil
  end
  local lnum = vim.api.nvim_win_get_cursor(win)[1]
  local r = math.floor((lnum - 1) / 2) + 1
  local ticket = state.buckets[state.columns[c].id][r]
  if not ticket then
    return nil
  end
  return ticket, c, r
end

--- h / l: move to the neighbouring column window, keeping the same row.
local function move_column(state, dir)
  local win = vim.api.nvim_get_current_win()
  local c = state.col_of_win[win]
  if not c then
    return
  end
  local target = math.max(1, math.min(#state.columns, c + dir))
  local lnum = vim.api.nvim_win_get_cursor(win)[1]
  local target_win = state.wins[target]
  vim.api.nvim_set_current_win(target_win)
  local maxln = vim.api.nvim_buf_line_count(state.bufs[target])
  vim.api.nvim_win_set_cursor(target_win, { math.max(1, math.min(lnum, maxln)), 0 })
end

--- j / k: jump to the next / previous CARD in the current column, not the
--- next / previous line. Each card owns two lines (title + meta); this always
--- lands on the target card's title line.
local function move_card_focus(state, dir)
  local win = vim.api.nvim_get_current_win()
  local c = state.col_of_win[win]
  if not c then
    return
  end
  local list = state.buckets[state.columns[c].id]
  if #list == 0 then
    return
  end
  local lnum = vim.api.nvim_win_get_cursor(win)[1]
  local r = math.floor((lnum - 1) / 2) + 1
  local step = dir * (vim.v.count1 > 0 and vim.v.count1 or 1)
  local target = math.max(1, math.min(#list, r + step))
  vim.api.nvim_win_set_cursor(win, { state.row_start[c][target], 0 })
end

--- Write a new status for the card under the cursor, then re-render.
local function move_card_to(state, target_index)
  local ticket = card_at_cursor(state)
  if not ticket then
    vim.notify("Kanban: no ticket under the cursor", vim.log.levels.WARN)
    return
  end
  local col = state.columns[target_index]
  if not col then
    return
  end
  local ok, err = tickets.write_status(ticket.path, col.status)
  if not ok then
    vim.notify("Kanban: " .. err, vim.log.levels.ERROR)
    return
  end
  ticket.status_raw = col.status
  render(state, { focus_path = ticket.path })
  vim.notify(("Kanban: %s -> %s"):format(ticket.title, col.title), vim.log.levels.INFO)
end

--- < / >: move a card to the neighbouring column.
local function move_card(state, dir)
  local _, c = card_at_cursor(state)
  if not c then
    vim.notify("Kanban: no ticket under the cursor", vim.log.levels.WARN)
    return
  end
  move_card_to(state, math.max(1, math.min(#state.columns, c + dir)))
end

local function choose_filter(state)
  local choices = { "All efforts" }
  vim.list_extend(choices, tickets.efforts(state.tickets))
  vim.ui.select(choices, { prompt = "Kanban: filter by effort" }, function(choice)
    if not choice or not vim.api.nvim_tabpage_is_valid(state.tabpage) then
      return
    end
    state.filter = choice ~= "All efforts" and choice or nil
    render(state, { focus_path = state.focus_path })
  end)
end

local function refresh(state)
  state.tickets = tickets.scan(state.root)
  render(state, { focus_path = state.focus_path })
  vim.notify(("Kanban: %d tickets from %s"):format(#state.tickets, state.root_short), vim.log.levels.INFO)
end

local function show_help()
  vim.notify(
    table.concat({
      "Kanban - local ticket board",
      "",
      "  j / k        jump to the next / previous card in the column (a count works: 3j)",
      "  gj / gk      move by screen line inside a wrapped title",
      "  h / l        jump to the previous / next column window",
      "  < / >        move the card to the previous / next column",
      "  <leader>1..5 move the card straight to that column (bare digits are counts)",
      "  <CR>         open the ticket file for editing (board closes)",
      "  o / O        open in a vertical / horizontal split",
      "  f            filter by effort",
      "  a            clear the effort filter",
      "  r            re-scan the files",
      "  q / <Esc>    close the board tab",
      "",
      "  <leader>k / :Kanban  reopen the board",
    }, "\n"),
    vim.log.levels.INFO,
    { title = "Kanban help" }
  )
end

function M.close()
  if not state then
    return
  end
  local s = state
  state = nil

  if vim.api.nvim_tabpage_is_valid(s.tabpage) then
    pcall(vim.api.nvim_set_current_tabpage, s.tabpage)
    if vim.fn.tabpagenr("$") > 1 then
      pcall(vim.cmd, "tabclose")
    else
      -- Only one tab left: collapse the splits into a single empty window.
      pcall(vim.cmd, "only")
      pcall(vim.cmd, "enew")
    end
  end
  if vim.api.nvim_tabpage_is_valid(s.origin_tabpage) then
    pcall(vim.api.nvim_set_current_tabpage, s.origin_tabpage)
  end
  for _, buf in ipairs(s.bufs) do
    if vim.api.nvim_buf_is_valid(buf) then
      pcall(vim.api.nvim_buf_delete, buf, { force = true })
    end
  end
end

--- Open a ticket as a normal file buffer so every other plugin applies.
local function open_ticket(state, split)
  local ticket = card_at_cursor(state)
  if not ticket then
    vim.notify("Kanban: no ticket under the cursor", vim.log.levels.WARN)
    return
  end
  local path = ticket.path
  M.close()
  vim.cmd((split and (split .. " ") or "edit ") .. vim.fn.fnameescape(path))
end

local function set_keymaps(state)
  for _, buf in ipairs(state.bufs) do
    local function kmap(lhs, fn, desc)
      vim.keymap.set("n", lhs, fn, { buffer = buf, desc = desc, nowait = true, silent = true })
    end

    kmap("q", M.close, "Kanban: close")
    kmap("<Esc>", M.close, "Kanban: close")
    kmap("<CR>", function()
      open_ticket(state, nil)
    end, "Kanban: open ticket")
    kmap("o", function()
      open_ticket(state, "vsplit")
    end, "Kanban: open ticket in vsplit")
    kmap("O", function()
      open_ticket(state, "split")
    end, "Kanban: open ticket in split")
    kmap("j", function()
      move_card_focus(state, 1)
    end, "Kanban: next card")
    kmap("k", function()
      move_card_focus(state, -1)
    end, "Kanban: previous card")
    kmap("h", function()
      move_column(state, -1)
    end, "Kanban: previous column")
    kmap("l", function()
      move_column(state, 1)
    end, "Kanban: next column")
    kmap("<", function()
      move_card(state, -1)
    end, "Kanban: move card left")
    kmap(">", function()
      move_card(state, 1)
    end, "Kanban: move card right")
    -- Deliberately NOT bare digits: those must stay free as Vim counts (3j).
    for i, col in ipairs(state.columns) do
      kmap("<leader>" .. i, function()
        move_card_to(state, i)
      end, "Kanban: move card to " .. col.title)
    end
    kmap("f", function()
      choose_filter(state)
    end, "Kanban: filter by effort")
    kmap("a", function()
      state.filter = nil
      render(state, { focus_path = state.focus_path })
    end, "Kanban: clear filter")
    kmap("r", function()
      refresh(state)
    end, "Kanban: refresh")
    kmap("?", show_help, "Kanban: help")
  end
end

--- Open (or rebuild) the board in a full-screen tab.
---@param opts table|nil { root = string }
function M.open(opts)
  opts = opts or {}
  local root = resolve_root(opts.root)
  if not root or vim.fn.isdirectory(root) ~= 1 then
    vim.notify(
      "Kanban: no .scratch found. Use :Kanban /path/to/.scratch or set vim.g.kanban_root",
      vim.log.levels.ERROR
    )
    return nil
  end

  M.close()
  ensure_highlights()

  local columns = cfg.columns
  local origin_tabpage = vim.api.nvim_get_current_tabpage()

  local bufs = {}
  for c = 1, #columns do
    local buf = vim.api.nvim_create_buf(false, true)
    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].bufhidden = "wipe"
    vim.bo[buf].swapfile = false
    vim.bo[buf].filetype = "kanban"
    bufs[c] = buf
  end

  vim.cmd("tabnew")
  local tabpage = vim.api.nvim_get_current_tabpage()
  local empty = vim.api.nvim_get_current_buf()

  local wins = {}
  vim.api.nvim_win_set_buf(0, bufs[1])
  wins[1] = vim.api.nvim_get_current_win()
  for c = 2, #columns do
    vim.cmd("rightbelow vsplit")
    vim.api.nvim_win_set_buf(0, bufs[c])
    wins[c] = vim.api.nvim_get_current_win()
  end
  pcall(vim.api.nvim_buf_delete, empty, { force = true })

  for _, win in ipairs(wins) do
    vim.wo[win].wrap = true
    vim.wo[win].linebreak = true
    vim.wo[win].breakindent = true
    vim.wo[win].cursorline = true
    vim.wo[win].number = false
    vim.wo[win].relativenumber = false
    vim.wo[win].signcolumn = "no"
    vim.wo[win].foldenable = false
    vim.wo[win].scrolloff = 2
  end

  local col_of_win = {}
  for c, win in ipairs(wins) do
    col_of_win[win] = c
  end

  state = {
    tabpage = tabpage,
    origin_tabpage = origin_tabpage,
    bufs = bufs,
    wins = wins,
    col_of_win = col_of_win,
    columns = columns,
    root = root,
    root_short = vim.fn.fnamemodify(root, ":~") or root,
    tickets = tickets.scan(root),
    filter = nil,
    focus_path = nil,
    buckets = {},
    row_start = {},
  }

  set_keymaps(state)
  render(state, {})
  return state
end

--- Toggle: handy for a single global keymap.
function M.toggle(opts)
  if state and vim.api.nvim_tabpage_is_valid(state.tabpage) then
    if vim.api.nvim_get_current_tabpage() == state.tabpage then
      M.close()
    else
      vim.api.nvim_set_current_tabpage(state.tabpage)
    end
  else
    M.open(opts)
  end
end

return M
