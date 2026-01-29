<h1 align="center">My custom Neovim configuration</h1>

<p align="center"><img src="https://github.com/user-attachments/assets/5fe2b095-1d53-41e9-8ce8-12288bc2b5e1" alt="Preview" /></p>

---

## Overview

This repo houses my day-to-day [NvChad v2.5](https://nvchad.com/news/v2.5_release) setup, tuned for Arch Linux. It ships batteries-included language support (Lua, Bash, Python, Rust, Go, JS/TS, Astro), a battle-tested Git toolbox (Neogit, Telescope pickers, Diffview, Vim-Fugitive, Gitsigns), Markdown preview with live updates, and consistent rounded UI chrome. The layout stays modular so you can toggle features by editing isolated specs under `lua/plugins/`.

---

## Requirements

| Dependency | Version / Notes |
| ---------- | --------------- |
| [Neovim](https://neovim.io/) | v0.11.5+ compiled with LuaJIT |
| [NvChad](https://nvchad.com/) | v2.5 (pulled automatically) |
| Fonts | Any Nerd Font (using JetBrains Mono Nerd Font) |
| Runtime tooling | Python 3.14+, Node.js 25.2.1+ |

> Older versions may work, but these are validated.

---

## Installation & First Run

1. Backup any existing config and clone this repo into `~/.config/nvim`.
2. Launch `nvim`. `bootstrap.lua` will clone `lazy.nvim`, sync NvChad, and pull every plugin listed in `lua/plugins/init.lua`.
3. Restart Neovim and run:
   - `:MasonInstallAll` to install all language servers, linters, and DAP binaries defined in `lua/plugins/override/mason.lua`.
   - `:Lazy sync` if you changed plugin specs.
   - `:TSUpdate` the first time to compile all Treesitter parsers declared in `lua/plugins/override/nvim-treesitter.lua`.

That is enough to get coding; NvChad’s default theme is replaced via `lua/plugins/override/base46.lua`, so expect the interface to match the screenshot above.

---

## Repository Layout

| Path | Purpose |
| ---- | ------- |
| `init.lua` | Entry point. Detects VSCode, sets globals, loads bootstrap + user modules. |
| `lua/gale/` | Custom runtime (globals, utils, autocmds, commands, OS tweaks). |
| `lua/plugins/` | Lazy specs. `override/` tweaks NvChad defaults, `spec/` adds third-party plugins, `local/` contains personal experiments. |
| `lua/configs/` | Tiny config tables that NvChad consumes (formatters, debugger helpers, etc.). |
| `queries/` & `snippets/` | Extra Treesitter queries and LuaSnip snippets. |
| `scripts/` | Utility scripts such as `update-lazy-imports.lua` to refresh `lua/plugins/init.lua` imports. |

---

## Daily Workflow & Commands

- `:UpdateAll` — runs `MasonUpdate`, `TSUpdate`, and `Lazy sync` (see `lua/gale/usercmds.lua`).
- `:FixJson`, `:CombineLists` — handy helpers for structured editing.
- `:TabuflineToggle`, `:ToggleWordCount`, `:DiagnosticsToggle` — UI/diagnostic switches defined under `lua/gale/usercmds.lua`.
- `:SrcPlugins` — re-source plugin import script after editing `lua/plugins/`.
- `:InspectTree` / `<leader>ts` — inspect Treesitter via Telescope or the built-in tree (see `lua/gale/utils.lua`).

Most plugins lazy-load; the few `lazy = false` entries (e.g., `dropbar.nvim`, `markview.nvim`) are essential UI components.

---

## Troubleshooting

- **Treesitter errors**: Make sure `parser/` files exist under `~/.local/share/nvim/lazy/nvim-treesitter`. Run `:TSUpdate` whenever you add parsers to `ensure_installed`.
- **Missing LSP binaries**: Re-run `:MasonInstallAll` after touching `lua/plugins/override/mason.lua`.
- **Notification spam / UI hiccups**: Use `:NoiceDismiss` (provided by `noice.nvim`) or toggle diagnostics via `:DiagnosticsToggle`.
- **General health**: `:checkhealth` plus `:InspectTree` and `:TSPlaygroundToggle` help diagnose highlight or parser issues.

If you find bugs or have ideas, open an issue/PR—I'm always listening.
