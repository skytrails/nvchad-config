# 我的 Neovim 配置

---

## 项目简介

这是基于 [NvChad v2.5](https://nvchad.com/news/v2.5_release) 的日常工作环境，主要针对 Arch Linux 调整。配置预设了 Lua、Bash、Python、Rust、Go 以及 JS/TS/Astro/Vue 的语法高亮与 LSP，提供 Neogit、Diffview、Gitsigns 等 Git 工具，支持浏览器 Markdown 预览，并通过 Base46 重绘成统一的圆角界面。

---

## 环境依赖

| 组件 | 要求 |
| ---- | ---- |
| Neovim | v0.11.5+（LuaJIT） |
| NvChad | v2.5（由 `lazy.nvim` 自动拉取） |
| 字体 | 任意 Nerd Font（推荐 JetBrains Mono Nerd Font） |
| 运行时 | Python 3.14+、Node.js 25.2.1+ |

> 老版本可能可用，但未在此配置中验证。

---

## 安装 & 首次运行

1. 备份旧的 `~/.config/nvim`，将本仓库克隆到该路径。
2. 首次启动 `nvim`，`lua/bootstrap.lua` 会自动下载 `lazy.nvim`、同步 NvChad，并装载 `lua/plugins/` 下的全部插件规格。
3. 重启后依次执行：
   - `:MasonInstallAll` 安装 `lua/plugins/override/mason.lua` 中声明的 LSP/DAP/格式化器。
   - `:TSUpdate` 编译 `lua/plugins/override/nvim-treesitter.lua` 中列出的 Treesitter parser。
   - 若改过插件清单，再运行 `:Lazy sync`。

现在即可使用；主题和 UI 由 `lua/plugins/override/base46.lua` 负责，无需额外操作。

---

## 仓库结构

| 路径 | 说明 |
| ---- | ---- |
| `init.lua` | 入口脚本：配置 leader、加载 bootstrap 以及 `gale` 命名空间。 |
| `lua/gale/` | 自定义模块，包含 globals、autocmd、usercmd 和工具函数。 |
| `lua/plugins/` | Lazy 插件规格：`override/` 修改 NvChad 默认行为，`spec/` 新增三方插件，`local/` 存放实验性模块。 |
| `lua/configs/` | 小型辅助配置，被 NvChad 或插件调用。 |
| `queries/` / `snippets/` | 自定义 Treesitter query、LuaSnip 片段。 |
| `scripts/` | 辅助脚本，例如 `update-lazy-imports.lua` 自动维护插件导入。 |

---

## 常用命令

- `:UpdateAll`：一次性执行 `MasonUpdate`、`TSUpdate`、`Lazy sync`。
- `:FixJson`、`:CombineLists`：结构化文本处理工具。
- `:TabuflineToggle`、`:ToggleWordCount`、`:DiagnosticsToggle`：UI / 诊断开关。
- `:SrcPlugins`：修改 `lua/plugins/` 后刷新 Lazy 导入列表。
- `:InspectTree` 或 `<leader>ts`：查看 Treesitter AST / Telescope treesitter picker。

---

## 故障排查

- **Treesitter 报错**：确认 `~/.local/share/nvim/lazy/nvim-treesitter/parser` 下存在 `.so`，缺失时跑 `:TSUpdate`。
- **LSP 缺组件**：变更 `mason` 配置后重新执行 `:MasonInstallAll`。
- **通知/浮窗异常**：用 `:NoiceDismiss` 清屏，或通过 `:DiagnosticsToggle` 临时关闭诊断。
- **通用健康检查**：`nvim --headless "+checkhealth" +qa`，并配合 `:TSPlaygroundToggle` 观察语法树。

遇到问题或有新想法，欢迎提 Issue/PR。
