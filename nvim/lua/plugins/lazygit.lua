return {
  "kdheepak/lazygit.nvim",
  lazy = true,
  cmd = {
    "LazyGit",
    "LazyGitConfig",
    "LazyGitCurrentFile",
    "LazyGitFilter",
    "LazyGitFilterCurrentFile",
  },
  -- optional for floating window border decoration
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  -- setting the keybinding for LazyGit with 'keys' is recommended in
  -- order to load the plugin when the command is run for the first time
  keys = {
    { "<leader>gg", "<cmd>LazyGit<cr>", desc = "lazygit" },
    {
      "<leader>gp",
      function()
        local Job = require("plenary.job")
        ---@diagnostic disable: missing-fields
        vim.notify("Pulling latest changes from remote", "info", { title = "Git pull" })

        Job:new({
          command = "git",
          args = {
            "pull",
          },
          cwd = vim.loop.cwd(),
          on_exit = function(j, return_val)
            if return_val ~= 0 then
              vim.notify("Failed to pull")
              return
            else
              vim.notify("Pulled latest changes from remote", "info", { title = "Git pull" })
            end
          end,
        }):start()
      end,
      desc = "Git pull",
    },
    config = function(opts)
      require("lazygit").setup(opts)
    end,
  },
}
