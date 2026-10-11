---@type NvPluginSpec
return {
  "mistricky/codesnap.nvim",
  event = "LspAttach",
  init = function()
    local map = vim.keymap.set
    map("x", "<leader>cc", "<cmd>CodeSnap<CR>", { desc = "Save selected code snapshot into clipboard" })
    map("x", "<leader>cs", "<cmd>CodeSnapSave<CR>", { desc = "Save selected code snapshot in ~/Pictures" })
  end,
  opts = {
    snapshot_config = {
      theme = "candy",
      code_config = {
        font_family = "JetBrainsMono Nerd Font",
        breadcrumbs = {
          enable = true,
          font_family = "JetBrainsMono Nerd Font",
        },
      },
      watermark = {
        content = "",
        font_family = "JetBrainsMono Nerd Font",
      },
    },
  },
  build = "make",
}
