# Dotfiles

Personal configuration files managed in `~/.config`.

## Quick Start (macOS)

Install all dependencies using Homebrew Bundle:

```bash
brew bundle --file=~/.config/Brewfile
```

This installs all formulae and casks required by the configurations in this repository.

## What's Included

| Config | Description |
|--------|-------------|
| `aerospace/` | Window manager (AeroSpace) |
| `hammerspoon/` | macOS automation (Hex-Neovim integration) |
| `herdr-app/` | Herdr app settings, keybindings, layouts and themes |
| `nvim/` | Neovim configuration |
| `opencode/` | OpenCode AI assistant settings |
| `sesh/` | Sesh session definitions |
| `sketchybar/` | macOS status bar |
| `tmux/` | Terminal multiplexer |
| `tmuxinator/` | Tmux session layouts |

### Hammerspoon Setup

The `hammerspoon/` config must be linked to Hammerspoon's expected location:

```bash
ln -s ~/.config/hammerspoon ~/.hammerspoon
```

Then open Hammerspoon and grant **Accessibility** permissions when prompted.
It will intercept the Option key when Neovim is focused, preparing Neovim
before Hex starts listening.

## OpenCode ↔ Herdr: `/new` creates a Herdr worktree tab

OpenCode's built-in **New session** creates a session tab *inside its own TUI
process*. This config takes over that command so `/new` (and `<leader>n`, and the
New session palette entry) instead:

1. creates a **fresh git worktree** of the current repository under
   `worktrees.directory` (`~/.herdr/worktrees/<repo>/<branch>` by default, the
   same convention Herdr's own "New worktree" uses), branched from the current
   `HEAD`;
2. opens a **new tab in the current Herdr space** with `opencode` running in
   that worktree, and focuses it.

So one Herdr tab == one OpenCode session == one isolated checkout. Both sessions
still live in OpenCode's shared background service.

Files:

| File | Role |
|------|------|
| `opencode/plugins/herdr-session/tui.ts` | CLI/TUI plugin that overrides `session.new` with a Herdr-aware `run` callback |
| `opencode/scripts/herdr-new-session.py` | Resolves the current Herdr terminal/space, creates the worktree, calls `herdr-app do tab.new` |
| `opencode/cli.json` | Loads the plugin; `tabs.mode: "off"` disables OpenCode's internal session tab strip |

Usage (all three names hit the same command; `/new` and `<leader>n` are the
taken-over built-ins, `/wt` and `/herdr` are extra aliases):

```text
/new                     # auto branch, e.g. oc-20261116-104500
/new fix-login           # name the branch / worktree / Herdr tab "fix-login"
/wt fix-login
/herdr fix-login
```

Why a plugin and not a `commands/new.md` custom command: `/new` is a built-in
TUI keymap command (not one of the replaceable custom commands `init`, `review`,
`goal`), and a custom command's `` !`shell` `` block is evaluated inside
OpenCode's **background service** — its environment is frozen at service start
(wrong `HC_TERMINAL_ID`, wrong `PWD`) and, critically, an empty shell block
still enqueues an empty user prompt. A TUI plugin runs in the terminal process
(correct pane identity), and its `run` callback submits no prompt at all.

The helper therefore resolves its Herdr terminal by **working directory**
(`hc ls` → live pane whose `cwd` equals the session's project directory), with
`HC_TERMINAL_ID` and `herdr-app status` only as tie-breakers. `herdr-app`/`hc`
resolve from `PATH` (fallback `~/.local/bin`); the space id comes from
`hc get … → labels.herdr.space`; the worktree root comes from
`herdr-app/settings.json` → `worktrees.directory`.

To preview without side effects:

```sh
HERDR_NEW_SESSION_DRY_RUN=1 python3 opencode/scripts/herdr-new-session.py fix-login
```

Notes / caveats:

- **Config is live in `main`, not here.** This worktree is the
  `opencode-herdr-integration` branch; the running apps read `~/.config`
  (the `main` worktree). Merge to `main` for the change to take effect — both
  apps hot-reload their config, no restart needed.
- Only this worktree was changed. Nothing under `~/.config` was modified.
- The plugin's `enabled` guard turns the override off when `HC_TERMINAL_ID`
  and `HERDR_APP_HOME` are both absent, so OpenCode outside Herdr keeps its
  normal new-session behaviour.
- Verified here with an isolated standalone TUI: the plugin loads, takes over
  `/new` (no duplicate built-in entry), and its `run` callback fires. Also
  verified: the helper's dry run, Herdr's `tab.new` argument shape, and
  `hc`/`herdr-app` resolution. What still needs a live check after merging is
  the final `herdr-app do tab.new` call itself (deliberately not run here — it
  would create a real tab in your window).

## Updating Dependencies

After adding or removing Homebrew packages, update the Brewfile:

```bash
brew bundle dump --file=~/.config/Brewfile --force
```

Then review the changes and commit them.

## Local-Only Files

Secrets and runtime state are intentionally untracked (see `.gitignore`), including
`opencode/service.json`, the OpenCode notifier state, and Herdr logs/sockets/telemetry.
Herdr's app-managed mods and assets are regenerated on launch; only user settings
under `herdr-app/` are tracked.
