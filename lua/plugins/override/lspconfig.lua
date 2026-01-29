---@type NvPluginSpec
local function mason_pkg_path(pkg)
  local ok, settings = pcall(require, "mason.settings")
  local root = (ok and settings.current.install_root_dir) or (vim.fn.stdpath "data" .. "/mason")
  return vim.fs.joinpath(root, "packages", pkg)
end

return {
  "neovim/nvim-lspconfig",
  config = function()
    dofile(vim.g.base46_cache .. "lsp")

    local glsp = require "gale.lsp"
    local lsp = glsp.lsp
    local volar_tsdk

    do
      local ok, mason_registry = pcall(require, "mason-registry")
      if ok then
        local ok_pkg, vue_root = pcall(mason_pkg_path "vue-language-server")
        if ok_pkg then
          local tsdk_path = vim.fs.joinpath(vue_root, "node_modules", "typescript", "lib")
          if vim.fn.isdirectory(tsdk_path) == 1 then
            volar_tsdk = tsdk_path
          end
        end
      end
    end

    local servers = {
      astro = {},
      bashls = {
        on_attach = function(client, bufnr)
          local filename = vim.api.nvim_buf_get_name(bufnr)
          if filename:match "%.env$" then
            vim.lsp.stop_client(client.id)
          end
        end,
      },
      clangd = {},
      css_variables = {},
      cssls = {},
      --[[ denols = {
        root_dir = lspconfig.util.root_pattern("deno.json", "deno.jsonc"),
      }, ]]
      -- eslint = {},
      -- fish_lsp = {},
      html = {},
      hyprls = {},
      gopls = {},
      jsonls = {},
      lua_ls = {
        settings = {
          Lua = {
            hint = { enable = true },
            telemetry = { enable = false },
            diagnostics = { globals = { "bit", "vim", "it", "describe", "before_each", "after_each" } },
            -- workspace libraries are set via lazydev
          },
        },
      },
      marksman = {},
      perlnavigator = {},
      pyright = {},
      ruff = {
        on_attach = function(client, _)
          -- prefer pyright's hover provider
          client.server_capabilities.hoverProvider = false
        end,
      },
      -- qmlls = {},
      somesass_ls = {},
      -- tailwindcss = {},
      taplo = {},
      vtsls = {
        single_file_support = false,
        settings = {
          javascript = {
            inlayHints = lsp.vtsls.inlay_hints_settings,
          },
          typescript = {
            inlayHints = lsp.vtsls.inlay_hints_settings,
          },
          vtsls = {
            tsserver = {
              globalPlugins = {
                "@styled/typescript-styled-plugin",
              },
            },
            experimental = {
              completion = {
                enableServerSideFuzzyMatch = true,
              },
            },
          },
        },
      },
      volar = {
        filetypes = { "vue" },
        init_options = {
          vue = {
            hybridMode = false,
          },
        },
      },
      yamlls = {},
      zls = {},
    }

    if volar_tsdk then
      servers.volar.init_options.typescript = {
        tsdk = volar_tsdk,
      }
    end

    for name, opts in pairs(servers) do
      opts.on_init = glsp.on_init
      opts.on_attach = glsp.generate_on_attach(opts.on_attach)
      opts.capabilities = glsp.capabilities
      vim.lsp.config(name, opts)
    end

    vim.lsp.enable(vim.tbl_keys(servers))

    -- LSP UI
    local border = "rounded"
    local x = vim.diagnostic.severity
    vim.diagnostic.config {
      virtual_text = false,
      signs = { text = { [x.ERROR] = "", [x.WARN] = "", [x.INFO] = "", [x.HINT] = "󰌵" } },
      float = { border = border },
      underline = true,
    }

    -- Gutter
    vim.fn.sign_define("CodeActionSign", { text = "󰉁", texthl = "CodeActionSignHl" })
  end,
}
