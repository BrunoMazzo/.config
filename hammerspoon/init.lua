-- Hex-Neovim Integration
--
-- What it does:
--   Hex (https://hex.ai) starts listening when you hold the Option key.
--   This script detects that Option press when Neovim is focused and sends
--   a configurable keystroke to Neovim so the cursor is in the right place
--   when Hex releases and inserts its result.
--
-- Requirements:
--   - Hammerspoon (installed via Homebrew in this repo's Brewfile)
--   - Accessibility permissions granted to Hammerspoon (it will prompt on first run)

local M = {}

-- ============================================================================
-- CONFIGURATION
-- ============================================================================

M.config = {
  -- Terminal emulators where Neovim might be running.
  -- Add or remove entries to match your setup.
  terminalApps = {
    ["cmux"] = true,
    ["Ghostty"] = true,
    ["iTerm2"] = true,
    ["Terminal"] = true,
    ["Kitty"] = true,
    ["Alacritty"] = true,
    ["WezTerm"] = true,
  },

  -- GUI Neovim apps that are Neovim themselves.
  guiNeovimApps = {
    ["Neovide"] = true,
    ["nvim-qt"] = true,
  },

  -- The Neovim leader key as a literal string (e.g., " " for Space).
  leaderKey = " ",

  -- Preparation command sent to Neovim on Option keydown.
  -- Each entry is either a literal character or the special token "leader".
  -- Examples:
  --   { "leader", "o" }     -> press leader then o
  --   { "i" }               -> press i (enter Insert mode)
  --   { "leader", "s", "p" } -> press leader then s then p
  prepareCommand = { "leader", "o" },

  -- If true, sends Escape before the prepareCommand to ensure Normal mode.
  -- This is important because leader mappings are Normal-mode commands.
  ensureNormalModeFirst = true,

  -- Delay between keystrokes (microseconds).
  -- Increase this if Neovim misses keys (e.g., 60000 = 60ms).
  keystrokeDelayUs = 40000,

  -- Path to the debug log file.
  logFilePath = os.getenv("HOME") .. "/.hammerspoon/hex_neovim.log",
}

-- ============================================================================
-- LOGGING
-- ============================================================================

local function log(msg)
  local path = M.config.logFilePath
  local f, err = io.open(path, "a")
  if not f then
    hs.printf("[Hex-Neovim] Failed to open log file: %s", err)
    return
  end
  local timestamp = os.date("%Y-%m-%d %H:%M:%S")
  f:write(string.format("[%s] %s\n", timestamp, msg))
  f:close()
end

-- ============================================================================
-- DETECTION
-- ============================================================================

-- Checks if any nvim process is currently running (heuristic for terminal
-- usage). Returns true as soon as one process is found.
local function isNvimProcessRunning()
  local handle = io.popen("pgrep -x nvim 2>/dev/null")
  if not handle then
    log("isNvimProcessRunning: io.popen failed")
    return false
  end
  local result = handle:read("*a")
  handle:close()
  local running = result ~= nil and result:match("%d+") ~= nil
  log(string.format("isNvimProcessRunning: %s", tostring(running)))
  return running
end

-- Returns true when the frontmost application is Neovim or a terminal that
-- likely contains a running Neovim session.
local function isNeovimFocused()
  local app = hs.application.frontmostApplication()
  if not app then
    log("isNeovimFocused: no frontmost application")
    return false
  end

  local appName = app:name()
  log(string.format("isNeovimFocused: frontmost app = '%s'", appName))

  -- Direct GUI Neovim match.
  if M.config.guiNeovimApps[appName] then
    log("isNeovimFocused: matched GUI Neovim app")
    return true
  end

  -- Terminal emulator match.
  if M.config.terminalApps[appName] then
    log("isNeovimFocused: matched terminal app")
    -- Heuristic 1: check the window title for Neovim indicators.
    local win = app:mainWindow()
    if win then
      local title = win:title() or ""
      log(string.format("isNeovimFocused: window title = '%s'", title))
      if title:find("NVIM") or title:find("nvim") then
        log("isNeovimFocused: title heuristic matched")
        return true
      end
    end

    -- Heuristic 2: fall back to checking if an nvim process exists.
    -- This can yield false positives when nvim is open in another terminal
    -- window, but it covers the common single-terminal workflow.
    local running = isNvimProcessRunning()
    if running then
      log("isNeovimFocused: process heuristic matched")
    else
      log("isNeovimFocused: no nvim process found")
    end
    return running
  end

  log("isNeovimFocused: app not in terminal or GUI lists")
  return false
end

-- ============================================================================
-- ACTION
-- ============================================================================

-- Sends a keystroke via Hammerspoon's native event poster.
-- Events are posted with NO modifiers, so the held Option key is ignored.
local function sendKey(key)
  local keyToSend = key
  if key == " " then
    keyToSend = "space"
  end

  log(string.format("sendKey: posting '%s' (as '%s')", key, keyToSend))
  hs.eventtap.keyStroke({}, keyToSend)
end

-- Prepares Neovim for Hex insertion.
local function prepareNeovimForHex()
  local cmd = M.config.prepareCommand
  if cmd == nil or #cmd == 0 then
    log("prepareNeovimForHex: prepareCommand is empty, nothing to send")
    return
  end

  log(string.format("prepareNeovimForHex: starting sequence (ensureNormal=%s, delay=%dus)",
    tostring(M.config.ensureNormalModeFirst), M.config.keystrokeDelayUs))

  -- First ensure Normal mode so the subsequent command behaves predictably.
  if M.config.ensureNormalModeFirst then
    sendKey("escape")
    hs.timer.usleep(M.config.keystrokeDelayUs)
  end

  for i, key in ipairs(cmd) do
    if key == "leader" then
      log(string.format("prepareNeovimForHex: sending leader ('%s')", M.config.leaderKey))
      sendKey(M.config.leaderKey)
    else
      log(string.format("prepareNeovimForHex: sending '%s'", key))
      sendKey(key)
    end

    -- Small delay between keys so Neovim / the terminal can process them.
    if i < #cmd then
      hs.timer.usleep(M.config.keystrokeDelayUs)
    end
  end

  log("prepareNeovimForHex: sequence complete")
end

-- ============================================================================
-- EVENT TAP
-- ============================================================================

-- Prevent duplicate triggers while the Option key is held.
local optionAlreadyPressed = false

-- macOS key codes for the Option / Alt keys.
local LEFT_OPTION = 0x3A  -- 58
local RIGHT_OPTION = 0x3D -- 61

-- Create an event tap that watches for modifier-key state changes.
M.eventTap = hs.eventtap.new({ hs.eventtap.event.types.flagsChanged }, function(event)
  local keyCode = event:getKeyCode()
  local flags = event:getFlags()

  -- Ignore non-Option modifier changes.
  if keyCode ~= LEFT_OPTION and keyCode ~= RIGHT_OPTION then
    return false
  end

  -- Option was just pressed.
  if flags.alt and not optionAlreadyPressed then
    optionAlreadyPressed = true
    log("eventTap: Option key pressed")

    if isNeovimFocused() then
      log("eventTap: Neovim is focused, scheduling preparation...")
      -- Run off the event-tap thread so the callback returns immediately
      -- and keystroke delays don't block other events.
      hs.timer.doAfter(0, function()
        prepareNeovimForHex()
      end)
    else
      log("eventTap: Neovim is NOT focused, skipping preparation")
    end

  -- Option was released.
  elseif not flags.alt then
    optionAlreadyPressed = false
    log("eventTap: Option key released")
  end

  -- ALWAYS return false so the event continues propagating.
  -- Hex relies on the same Option keydown event to start listening.
  return false
end)

-- ============================================================================
-- STARTUP
-- ============================================================================

M.eventTap:start()

log("--- Hammerspoon config loaded ---")
log(string.format("Leader key: '%s'", M.config.leaderKey))
log(string.format("Prepare command: %s", hs.inspect(M.config.prepareCommand)))

hs.notify.new({
  title = "Hammerspoon",
  informativeText = "Hex-Neovim integration active",
}):send()

return M
