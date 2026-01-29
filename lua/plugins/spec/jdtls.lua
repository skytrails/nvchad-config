---@type NvPluginSpec
local function mason_pkg_path(pkg)
  local ok, settings = pcall(require, "mason.settings")
  local root = (ok and settings.current.install_root_dir) or (vim.fn.stdpath "data" .. "/mason")
  print("----", root)
  return vim.fs.joinpath(root, "packages", pkg)
end

return {
  "mfussenegger/nvim-jdtls",
  ft = { "java" },
  config = function()
    local jdtls = require "jdtls"
    print(vim.fn.stdpath "data")

    local jdtls_path = vim.fn.stdpath "data" .. "/mason/packages/jdtls"

    local lombok_jar = jdtls_path .. "/lombok.jar"

    local root_markers = { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }
    local root_dir = require("jdtls.setup").find_root(root_markers)

    if root_dir == nil then
      return
    end

    local workspace_dir = vim.fn.stdpath "data" .. "/jdtls-workspace/" .. vim.fn.fnamemodify(root_dir, ":p:h:t")

    local config = {
      cmd = {
        "java",
        "-javaagent:" .. lombok_jar,
        "-jar",
        jdtls_path .. "/plugins/org.eclipse.equinox.launcher_1.7.100.v20251111-0406.jar",
        "-configuration",
        jdtls_path .. "/config_mac",
        "-data",
        workspace_dir,
      },

      root_dir = root_dir,

      settings = {
        java = {
          signatureHelp = { enabled = true },
          contentProvider = { preferred = "fernflower" },
          completion = {
            favoriteStaticMembers = {
              "org.junit.jupiter.api.Assertions.*",
              "java.util.Objects.requireNonNull",
            },
          },
          sources = {
            organizeImports = {
              starThreshold = 9999,
              staticStarThreshold = 9999,
            },
          },
        },
      },

      init_options = {
        bundles = {},
        extendedClientCapabilities = require("jdtls").extendedClientCapabilities,
        settings = {
          java = {
            import = {
              gradle = {
                buildServer = {
                  enabled = true,
                },
              },
            },
          },
        },
      },
    }

    jdtls.start_or_attach(config)
  end,
}
