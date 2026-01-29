---@type NvPluginSpec
return {
  "williamboman/mason.nvim",
  opts = {
    ui = { border = "rounded" },
    ensure_installed = {
      -- LSP servers
      "astro-language-server",
      "bash-language-server",
      "clangd",
      "css-variables-language-server",
      "css-lsp",
      -- "fish-lsp",
      "gopls",
      "html-lsp",
      "hyprls",
      "jdtls",
      "json-lsp",
      "lua-language-server",
      "marksman",
      "perlnavigator",
      "pyright",
      "ruff",
      "taplo",
      "vtsls",
      "vue-language-server",
      "yaml-language-server",
      "zls",
      -- Formatters / linters
      "biome",
      "markdownlint",
      "prettier",
      "shfmt",
      "stylua",
      "yamlfmt",
    },
  },
}
