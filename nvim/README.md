# Bruno's Neovim Configuration

A comprehensive Neovim configuration built on top of [LazyVim](https://github.com/LazyVim/LazyVim) with extensive customizations for modern development workflows.

## 🚀 Features

- **Language Support**: Go, TypeScript/JavaScript, Swift, Lua with full LSP integration
- **AI Integration**: GitHub Copilot and Avante.nvim for AI-powered coding assistance
- **Advanced Completion**: Blink.cmp with Copilot integration
- **Debugging**: Full DAP setup for Go, JavaScript, and other languages
- **Database Management**: Built-in database client with nvim-dbee
- **Git Integration**: Comprehensive Git workflow with LazyGit, Gitsigns, and Fugitive
- **Testing**: Integrated test runner with Neotest
- **Session Management**: Auto-session restoration
- **Modern UI**: Beautiful interface with Catppuccin theme, Lualine, and Bufferline

## 📋 Requirements

### Essential Dependencies

1. **Neovim >= 0.10.0**
   ```bash
   # macOS
   brew install neovim
   
   # Ubuntu/Debian
   sudo apt install neovim
   
   # Arch Linux
   sudo pacman -S neovim
   ```

2. **Git** (for plugin management)
   ```bash
   # Usually pre-installed, verify with:
   git --version
   ```

3. **Node.js >= 18** (for TypeScript/JavaScript LSP and tools)
   ```bash
   # macOS
   brew install node
   
   # Ubuntu/Debian
   curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
   sudo apt-get install -y nodejs
   ```

4. **Go >= 1.21** (for Go development and tools)
   ```bash
   # macOS
   brew install go
   
   # Linux: Download from https://golang.org/dl/
   ```

5. **Python 3** (for various tools and plugins)
   ```bash
   # macOS
   brew install python
   
   # Ubuntu/Debian
   sudo apt install python3 python3-pip
   ```

### macOS Specific Requirements

6. **Xcode Command Line Tools** (for Swift development)
   ```bash
   xcode-select --install
   ```

### Optional but Recommended

7. **Ripgrep** (for fast searching)
   ```bash
   # macOS
   brew install ripgrep
   
   # Ubuntu/Debian
   sudo apt install ripgrep
   ```

8. **FZF** (for fuzzy finding)
   ```bash
   # macOS
   brew install fzf
   
   # Ubuntu/Debian
   sudo apt install fzf
   ```

9. **LazyGit** (for Git UI)
   ```bash
   # macOS
   brew install lazygit
   
   # Ubuntu/Debian
   sudo apt install lazygit
   ```

10. **Tmux** (for terminal multiplexing integration)
    ```bash
    # macOS
    brew install tmux
    
    # Ubuntu/Debian
    sudo apt install tmux
    ```

## 🔧 Installation

1. **Backup existing Neovim configuration**
   ```bash
   mv ~/.config/nvim ~/.config/nvim.backup
   mv ~/.local/share/nvim ~/.local/share/nvim.backup
   ```

2. **Clone this configuration**
   ```bash
   git clone <your-repo-url> ~/.config/nvim
   ```

3. **Start Neovim**
   ```bash
   nvim
   ```
   
   The configuration will automatically:
   - Install Lazy.nvim plugin manager
   - Download and install all plugins
   - Set up LSP servers via Mason

4. **Post-installation setup**
   - Run `:checkhealth` to verify everything is working
   - Run `:Mason` to ensure all LSP servers and tools are installed

## 📦 Key Plugins

### Core Framework
- **[LazyVim](https://github.com/LazyVim/LazyVim)**: Base configuration framework
- **[lazy.nvim](https://github.com/folke/lazy.nvim)**: Modern plugin manager

### Language Support & LSP
- **[nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)**: LSP configurations
- **[mason.nvim](https://github.com/williamboman/mason.nvim)**: LSP server installer
- **[mason-lspconfig.nvim](https://github.com/williamboman/mason-lspconfig.nvim)**: Mason-LSP integration
- **[nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)**: Syntax highlighting and parsing

### Completion & AI
- **[blink.cmp](https://github.com/Saghen/blink.cmp)**: Fast completion engine
- **[copilot.lua](https://github.com/zbirenbaum/copilot.lua)**: GitHub Copilot integration
- **[avante.nvim](https://github.com/yetone/avante.nvim)**: AI-powered coding assistant

### File Management & Navigation
- **[neo-tree.nvim](https://github.com/nvim-neo-tree/neo-tree.nvim)**: File explorer
- **[fzf-lua](https://github.com/ibhagwan/fzf-lua)**: Fuzzy finder
- **[flash.nvim](https://github.com/folke/flash.nvim)**: Enhanced navigation

### Git Integration
- **[lazygit.nvim](https://github.com/kdheepak/lazygit.nvim)**: LazyGit integration
- **[gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim)**: Git signs in gutter
- **[vim-fugitive](https://github.com/tpope/vim-fugitive)**: Git commands

### Debugging & Testing
- **[nvim-dap](https://github.com/mfussenegger/nvim-dap)**: Debug Adapter Protocol
- **[nvim-dap-ui](https://github.com/rcarriga/nvim-dap-ui)**: Debug UI
- **[nvim-dap-go](https://github.com/leoluz/nvim-dap-go)**: Go debugging
- **[neotest](https://github.com/nvim-neotest/neotest)**: Test runner

### UI & Appearance
- **[catppuccin](https://github.com/catppuccin/nvim)**: Color scheme
- **[lualine.nvim](https://github.com/nvim-lualine/lualine.nvim)**: Status line
- **[bufferline.nvim](https://github.com/akinsho/bufferline.nvim)**: Buffer tabs
- **[noice.nvim](https://github.com/folke/noice.nvim)**: Enhanced UI messages

### Productivity
- **[auto-session](https://github.com/rmagatti/auto-session)**: Session management
- **[auto-save.nvim](https://github.com/okuuva/auto-save.nvim)**: Automatic file saving
- **[which-key.nvim](https://github.com/folke/which-key.nvim)**: Keybinding hints
- **[nvim-dbee](https://github.com/kndndrj/nvim-dbee)**: Database client

### Code Quality
- **[conform.nvim](https://github.com/stevearc/conform.nvim)**: Code formatting
- **[nvim-lint](https://github.com/mfussenegger/nvim-lint)**: Linting
- **[trouble.nvim](https://github.com/folke/trouble.nvim)**: Diagnostics panel

## ⚙️ Language-Specific Setup

### Go Development
- **LSP**: `gopls` with custom settings for integration tests
- **Debugging**: Delve debugger integration
- **Testing**: Neotest with Go adapter
- **Auto-formatting**: On save with import organization

### TypeScript/JavaScript
- **LSP**: `vtsls` with enhanced completion and inlay hints
- **Debugging**: JS Debug Adapter
- **Linting**: ESLint integration
- **Formatting**: Prettier support

### Swift/iOS Development
- **LSP**: SourceKit-LSP integration
- **Build System**: Xcodebuild.nvim for iOS projects
- **Debugging**: LLDB integration

### Lua Development
- **LSP**: `lua_ls` with Neovim API support
- **Formatting**: Stylua integration
- **Development**: LazyDev for enhanced Lua development

## 🎯 Key Keybindings

### Leader Key
- **Leader**: `<Space>`
- **Local Leader**: `\`

### Essential Mappings
- `<leader>ff` - Find files
- `<leader>fg` - Live grep
- `<leader>fb` - Find buffers
- `<leader>e` - Toggle file explorer
- `<leader>gg` - Open LazyGit
- `<leader>ca` - Code actions
- `<leader>rn` - Rename symbol
- `gd` - Go to definition
- `gr` - Find references
- `K` - Show documentation

## 🔍 Troubleshooting

### Common Issues

1. **LSP servers not working**
   ```bash
   :Mason
   # Ensure required servers are installed
   ```

2. **Treesitter parsing errors**
   ```bash
   :TSUpdate
   # Update all parsers
   ```

3. **Plugin installation issues**
   ```bash
   :Lazy clean
   :Lazy sync
   # Clean and reinstall plugins
   ```

4. **Performance issues**
   ```bash
   :checkhealth
   # Check for potential issues
   ```

### Health Checks
Run `:checkhealth` to verify:
- Neovim version compatibility
- Required dependencies
- Plugin functionality
- LSP server status

## 📝 Customization

This configuration is highly modular. Key customization points:

- **Plugins**: Add/remove in `lua/plugins/`
- **Keymaps**: Modify in `lua/config/keymaps.lua`
- **Options**: Adjust in `lua/config/options.lua`
- **LSP Settings**: Customize in `lua/plugins/nvim-lspconfig.lua`

## 🤝 Contributing

Feel free to fork and customize this configuration for your needs. If you find improvements or fixes, pull requests are welcome!

## 📄 License

This configuration is provided as-is under the MIT License. See the original LazyVim license for base framework terms.