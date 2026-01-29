# Repository Guidelines

## Project Structure & Module Organization
The entry point is `init.lua`, which bootstraps NvChad and pulls settings from `lua/`. Core behavior lives in `lua/options.lua`, `lua/mappings.lua`, and `lua/chadrc.lua`, while feature modules reside under `lua/configs/` and `lua/plugins/` (each plugin spec is a dedicated Lua file returning a Lazy table). Custom UI and helpers live in `lua/gale/` and `lua/themes/`. Treesitter overrides sit in `queries/`, snippets in `snippets/`, and helper tooling lives in `scripts/` (e.g., `scripts/update-lazy-imports.lua`). Keep `lazy-lock.json` in sync whenever plugin versions change.

## Build, Test, and Development Commands
- `nvim --headless "+Lazy sync" +qa` — install/validate plugins against `lazy-lock.json`.
- `nvim --headless "+MasonInstallAll" +qa` — ensure language servers, linters, and DAP tools from `mason.lua` are present.
- `nvim` — launch interactively to verify UI changes, mappings, or plugin wiring.
- `nvim --headless "+luafile scripts/update-lazy-imports.lua" +qa` — refresh NvChad import annotations when adding Lazy modules.

## Coding Style & Naming Conventions
Use 2-space indentation and idiomatic Lua module returns (`local M = {}` followed by `return M`). Name plugin specs after the upstream repo (`lua/plugins/telescope.lua`) and keep configuration helpers under `lua/configs/<feature>.lua`. Prefer descriptive keymap identifiers (e.g., `gale.mappings.git_stage`). Follow NvChad defaults for options and rely on Conform/none-ls definitions already present; add formatter/linter configs adjacent to the plugin that provides them.

## Testing Guidelines
There is no standalone test suite; validation is editor-driven. Run `nvim --headless "+checkhealth" +qa` after adding plugins or Treesitter queries. For language-specific tweaks, open representative files and use `:InspectTree`, `:TSPlaygroundToggle`, or LSP hover/code actions to confirm behavior. Avoid merging changes that introduce startup errors (`:messages`) or Lazy warnings; test with both an empty buffer and a project workspace.

## Commit & Pull Request Guidelines
Commits follow Conventional Commits with scopes (`feat(lsp): add pyright`, `chore(todo-comments): update`). Keep changes atomic and mention affected modules. Pull requests should describe the motivation, highlight user-visible effects, and link issues or screenshots when altering UI components. Include reproduction steps for bugs and note any manual commands contributors must run (`Lazy sync`, `MasonInstallAll`). Ensure PRs leave the config bootable for both Arch Linux and headless CI scenarios.

## Security & Configuration Tips
Never hard-code paths or secrets; prefer environment variables or NvChad globals. When adding scripts or commands, keep them POSIX-compatible since contributors may run them from macOS or Linux. Document new dependencies in `README.md` and update `lazy-lock.json` so other agents can reproduce your environment without guesswork.
