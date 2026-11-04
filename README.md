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
| `ralph/` | Ralph task runner scripts |
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

## Updating Dependencies

After adding or removing Homebrew packages, update the Brewfile:

```bash
brew bundle dump --file=~/.config/Brewfile --force
```

Then review the changes and commit them.

## Local-Only Files

Secrets and runtime state are intentionally untracked (see `.gitignore`), including
`opencode/service.json`, the OpenCode notifier state, Herdr logs/sockets/telemetry,
and Ralph loop progress. Herdr's app-managed mods and assets are regenerated on
launch; only user settings under `herdr-app/` are tracked.
