# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a personal Neovim configuration based on kickstart.nvim. It's a single-file Lua configuration (`init.lua`) with optional modular plugin configs in `lua/kickstart/plugins/`.

## Key Configuration Details

- **Leader key**: Space (`<leader>`)
- **Plugin manager**: lazy.nvim (auto-bootstraps on first run)
- **LSP management**: mason.nvim with mason-lspconfig
- **Autocompletion**: blink.cmp with LuaSnip snippets
- **Fuzzy finder**: Telescope
- **Formatter**: conform.nvim (formats on save)
- **Git integration**: gitsigns.nvim and neogit
- **Colorscheme**: catppuccin

## Architecture

```
init.lua                          # Main config: options, keymaps, plugins
lua/
  kickstart/
    health.lua                    # :checkhealth diagnostics
    plugins/                      # Optional plugin configs (require to enable)
      gitsigns.lua               # Git signs keymaps (currently enabled)
      autopairs.lua              # Auto bracket pairing
      debug.lua                  # DAP debugging
      indent_line.lua            # Indent guides
      lint.lua                   # Linting
      neo-tree.lua               # File explorer
  custom/plugins/                 # User custom plugins (empty by default)
```

## Configured LSP Servers

- `lua_ls` - Lua (with lazydev.nvim for Neovim API completion)
- `ts_ls` - TypeScript/JavaScript
- `rust_analyzer` - Rust (with proc macro support enabled)

## Key Keymaps

Search (`<leader>s`):
- `<leader>sf` - Find files
- `<leader>sg` - Live grep
- `<leader>sh` - Help tags
- `<leader>sk` - Keymaps
- `<leader>/` - Fuzzy search current buffer

LSP (`gr` prefix):
- `grd` - Go to definition
- `grr` - Find references
- `gri` - Go to implementation
- `grn` - Rename symbol
- `gra` - Code actions

Git (`<leader>h`):
- `<leader>hs` - Stage hunk
- `<leader>hr` - Reset hunk
- `<leader>hp` - Preview hunk
- `<leader>hb` - Blame line

Other:
- `<leader>f` - Format buffer
- `<leader><leader>` - Find buffers
- `<C-n>/<C-p>` - Navigate quickfix list
- `<C-space>` - Expand treesitter selection

## Adding Plugins

1. For kickstart optional plugins: uncomment the `require` line in `init.lua` (lines 937-941)
2. For custom plugins: add to `lua/custom/plugins/` and uncomment `{ import = 'custom.plugins' }` in `init.lua`

## Useful Commands

- `:Lazy` - Plugin manager UI
- `:Mason` - LSP/tool installer UI
- `:checkhealth` - Verify setup
- `:ConformInfo` - Check formatter status
