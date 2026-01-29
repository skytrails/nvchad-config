---@type NvPluginSpec
return {
  "mfussenegger/nvim-jdtls",
  ft = { "java" },
  config = function()
    local jdtls = require "jdtls"
    local glsp = require "gale.lsp"
    local root_dir = require("jdtls.setup").find_root { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }

    if not root_dir then
      vim.notify("Unable to start jdtls, no project root found", vim.log.levels.WARN)
      return
    end

    local jdtls_cmd = vim.fn.exepath "jdtls"
    if jdtls_cmd == "" then
      vim.notify("Install jdtls via :MasonInstall jdtls", vim.log.levels.WARN)
      return
    end

    local workspace_dir = vim.fs.joinpath(vim.fn.stdpath "data", "jdtls-workspaces", vim.fs.basename(root_dir))
    vim.fn.mkdir(workspace_dir, "p")

    local config = {
      cmd = { jdtls_cmd, "-data", workspace_dir },
      root_dir = root_dir,
      settings = {
        java = {},
      },
      capabilities = glsp.capabilities,
      on_attach = glsp.generate_on_attach(function(_, bufnr)
        local function map(lhs, rhs, desc)
          vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = desc })
        end

        map("<leader>oi", jdtls.organize_imports, "Java organize imports")
        map("<leader>ev", jdtls.extract_variable, "Java extract variable")
        map("<leader>ec", jdtls.extract_constant, "Java extract constant")
        map("<leader>em", jdtls.extract_method, "Java extract method")
      end),
    }

    jdtls.start_or_attach(config)
  end,
}
