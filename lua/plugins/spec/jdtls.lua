---@type NvPluginSpec
local function get_jdtls_config_dir(root)
  local uname = vim.loop.os_uname()
  local sys = uname.sysname
  local arch = uname.machine

  if sys == "Darwin" then
    return vim.fs.joinpath(root, arch == "arm64" and "config_mac_arm" or "config_mac")
  elseif sys == "Linux" then
    return vim.fs.joinpath(root, arch == "aarch64" and "config_linux_arm" or "config_linux")
  elseif sys == "Windows_NT" then
    return vim.fs.joinpath(root, "config_win")
  end

  return vim.fs.joinpath(root, "config_linux")
end

return {
  "mfussenegger/nvim-jdtls",
  ft = { "java" },
  config = function()
    local jdtls = require "jdtls"
    local glsp = require "gale.lsp"
    local root_dir = require("jdtls.setup").find_root { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }

    if not root_dir then
      vim.notify("无法找到 Java 项目的根目录，jdtls 未启动", vim.log.levels.WARN)
      return
    end

    local java_cmd = vim.fn.exepath "java"
    if java_cmd == "" then
      vim.notify("未找到 java 可执行文件，无法启动 jdtls", vim.log.levels.ERROR)
      return
    end

    local ok, mason_registry = pcall(require, "mason-registry")
    if not ok then
      vim.notify("mason.nvim 尚未加载，无法解析 jdtls 路径", vim.log.levels.ERROR)
      return
    end

    local ok_pkg, jdtls_pkg = pcall(mason_registry.get_package, "jdtls")
    if not ok_pkg then
      vim.notify("尚未通过 Mason 安装 jdtls，请运行 :MasonInstall jdtls", vim.log.levels.ERROR)
      return
    end

    -- local jdtls_path = jdtls_pkg:get_install_path()
    local ok, settings = pcall(require, "mason.settings")
    local root = (ok and settings.current.install_root_dir) or (vim.fn.stdpath "data" .. "/mason")
    local jdtls_path = vim.fs.joinpath(root, "packages", pkg) .. "/jdtls"
    local launcher = vim.fn.glob(vim.fs.joinpath(jdtls_path, "plugins", "org.eclipse.equinox.launcher_*.jar"), 0, 1)[1]
    local config_dir = get_jdtls_config_dir(jdtls_path)
    local lombok_path = vim.fs.joinpath(jdtls_path, "lombok.jar")
    local workspace =
      vim.fs.joinpath(vim.fn.stdpath "data", "jdtls-workspace/" .. vim.fn.fnamemodify(root_dir, ":p:h:t"))
    vim.fn.mkdir(workspace, "p")

    if not launcher or vim.fn.filereadable(launcher) == 0 then
      vim.notify("未找到 jdtls 启动器 jar，无法启动", vim.log.levels.ERROR)
      return
    end

    print(java_cmd)
    local cmd = {
      -- "/opt/homebrew/opt/openjdk@17/bin/java",
      java_cmd,
      "-Declipse.application=org.eclipse.jdt.ls.core.id1",
      "-Dosgi.bundles.defaultStartLevel=4",
      "-Declipse.product=org.eclipse.jdt.ls.core.product",
      "-Dlog.protocol=true",
      "-Dlog.level=ALL",
      "-Xms1g",
      -- "--add-modules=ALL-SYSTEM",
      "--add-opens",
      "java.base/java.util=ALL-UNNAMED",
      "--add-opens",
      "java.base/java.lang=ALL-UNNAMED",
    }

    if vim.fn.filereadable(lombok_path) == 1 then
      table.insert(cmd, "-javaagent:" .. lombok_path)
      table.insert(cmd, "-Xbootclasspath/a:" .. lombok_path)
    end

    vim.list_extend(cmd, {
      "-jar",
      launcher,
      "-configuration",
      config_dir,
      "-data",
      workspace,
    })

    local config = {
      cmd = cmd,
      root_dir = root_dir,
      capabilities = glsp.capabilities,
      on_attach = glsp.generate_on_attach(function(_, bufnr)
        local map = function(lhs, rhs, desc)
          vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = desc })
        end

        map("<leader>oi", jdtls.organize_imports, "Java organize imports")
        map("<leader>ev", jdtls.extract_variable, "Java extract variable")
        map("<leader>ec", jdtls.extract_constant, "Java extract constant")
        map("<leader>em", jdtls.extract_method, "Java extract method")
      end),
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
        extendedClientCapabilities = jdtls.extendedClientCapabilities,
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
