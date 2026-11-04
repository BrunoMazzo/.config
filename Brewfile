# Brewfile for ~/.config dotfiles
# Usage: brew bundle --file=~/.config/Brewfile
# This installs all Homebrew dependencies required for this configuration.

# --- Core AI & Editor ---
brew "opencode"          # AI assistant (https://opencode.ai)
brew "node"              # Required for opencode MCP servers (npx)
brew "neovim"            # Editor with extensive customizations

# --- Development Languages ---
brew "go"                # Go development
brew "python"            # Python support for various tools
brew "lua"               # Lua development
brew "luarocks"          # Lua package manager

# --- Terminal & Multiplexer ---
brew "tmux"              # Terminal multiplexer
brew "tmuxinator"        # Tmux session manager
brew "herdr"             # Terminal-native agent multiplexer (https://herdr.dev)

# --- Window Manager & UI ---
cask "aerospace"         # i3-like window manager for macOS
brew "sketchybar"        # macOS status bar (used with aerospace)
brew "borders"           # Window borders (used with aerospace)
brew "nowplaying-cli"    # Media info for sketchybar

# --- macOS Automation ---
# Hammerspoon bridges Hex (Option-key AI assistant) with Neovim. When Option is
# pressed and Neovim is focused, it sends a preparation keystroke so Hex inserts
# at the right cursor position on release.
cask "hammerspoon"

# --- Git & GitHub ---
brew "git-lfs"           # Git Large File Storage
brew "lazygit"           # Terminal UI for git
brew "lazydocker"        # Terminal UI for docker
brew "gh"                # GitHub CLI
brew "glab"              # GitLab CLI

# --- Search & Navigation ---
brew "ripgrep"           # Fast grep alternative
brew "fzf"               # Fuzzy finder
brew "fd"                # Fast find alternative
brew "bat"               # Better cat with syntax highlighting
brew "zoxide"            # Smarter cd command (cd with z)
brew "tree-sitter"       # Syntax parsing for neovim

# --- Utilities ---
brew "jq"                # JSON processor
brew "coreutils"         # GNU core utilities

# --- Fonts ---
cask "font-hack-nerd-font"       # Primary icon font for sketchybar & terminal
cask "font-monaspice-nerd-font"  # Additional coding font

# === PACKAGES NOT IN BREWFILE (added for review) ===
# The following packages were found installed but were not in the Brewfile.
# Please review and remove any you don't want to track, or organize them into sections above.
# Note: Dependency-only packages have been removed. Only top-level packages remain.

# --- Top-Level Formulas (not dependencies) ---
brew "act"	# Run your GitHub Actions locally
brew "awscli-local"	# Thin wrapper around the `aws` command-line interface for use with LocalStack
brew "bash"	# Bourne-Again SHell, a UNIX command interpreter
brew "bc"	# Arbitrary precision numeric processing language
brew "black"	# Python code formatter
brew "colima"	# Container runtimes on MacOS (and Linux) with minimal setup
brew "docker"	# Pack, ship and run any application as a lightweight container
brew "docker-compose"	# Isolated development environments using Docker
brew "docker-credential-helper"	# Platform keystore credential helper for Docker
brew "gawk"	# GNU awk utility
brew "gnu-sed"	# GNU implementation of the famous stream editor
brew "gogcli"	# Google CLI for Gmail, Calendar, Drive, Docs, Sheets, and more
brew "gradle"	# Open-source build automation tool based on the Groovy and Kotlin DSL
brew "icu4c@77"	# C/C++ and Java libraries for Unicode and globalization
brew "isort"	# Sort Python imports automatically
brew "llvm"	# Next-gen compiler infrastructure
brew "localstack"	# Fully functional local AWS cloud stack
brew "memo"	# No description
brew "mercurial"	# Scalable distributed version control system
brew "mint"	# Dependency manager that installs and runs Swift command-line tool packages
brew "mise"	# Polyglot runtime manager (asdf rust clone)
brew "obsidian-cli"	# 
brew "openjdk@21"	# Development kit for the Java programming language
brew "pandoc"	# Swiss-army knife of markup format conversion
brew "pipx"	# Execute binaries from Python packages in isolated environments
brew "python@3.11"	# Interpreted, interactive, object-oriented programming language
brew "qemu"	# Generic machine emulator and virtualizer
brew "rbenv"	# Ruby version manager
brew "sourcekitten"	# Framework and command-line tool for interacting with SourceKit
brew "swiftformat"	# Formatting tool for reformatting Swift code
brew "swiftlint"	# Tool to enforce Swift style and conventions
brew "terraform"	# Terraform
brew "terraform-local"	# CLI wrapper to deploy your Terraform applications directly to LocalStack
brew "unbound"	# Validating, recursive, caching DNS resolver
brew "wget"	# Internet file retriever
brew "xcbeautify"	# Little beautifier tool for xcodebuild
brew "xcode-build-server"	# Build server protocol implementation for integrating Xcode with sourcekit-lsp
brew "yarn"	# JavaScript package manager
brew "zsh-autocomplete"	# Real-time type-ahead completion for Zsh

# --- Casks ---
cask "font-monaspace-nerd-font"	# None
cask "font-noto-sans-symbols-2"	# None
cask "ghostty"	# Terminal emulator that uses platform-native UI and GPU acceleration
