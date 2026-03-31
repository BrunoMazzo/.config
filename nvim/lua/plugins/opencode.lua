return {
  "NickvanDyke/opencode.nvim",
  version = "*",
  dependencies = {
    {
      -- `snacks.nvim` integration is recommended, but optional
      ---@module "snacks" <- Loads `snacks.nvim` types for configuration intellisense
      "folke/snacks.nvim",
      optional = true,
      opts = {
        input = {}, -- Enhances `ask()`
        picker = { -- Enhances `select()`
          actions = {
            opencode_send = function(...)
              return require("opencode").snacks_picker_send(...)
            end,
          },
          win = {
            input = {
              keys = {
                ["<a-a>"] = { "opencode_send", mode = { "n", "i" } },
              },
            },
          },
        },
      },
    },
  },
  config = function()
    ---@type opencode.Opts
    -- vim.g.opencode_opts = {
    -- provider = {
    --   enabled = "tmux",
    --   tmux = {
    --     options = "-h",
    --   },
    -- },
    -- Your configuration, if any — see `lua/opencode/config.lua`
    -- }

    -- Required for `opts.auto_reload`
    vim.o.autoread = true

    -- Recommended/example keymaps
    -- Recommended/example keymaps
    vim.keymap.set({ "n", "x" }, "<leader>oa", function()
      require("opencode").ask("@this: ", { submit = true })
    end, { desc = "Ask about this" })
    vim.keymap.set({ "n", "x" }, "<leader>o+", function()
      require("opencode").prompt("@this")
    end, { desc = "Add this" })
    vim.keymap.set({ "n", "x" }, "<leader>oe", function()
      require("opencode").prompt("Explain @this and its context", { submit = true })
    end, { desc = "Explain this" })
    vim.keymap.set({ "n", "x" }, "<leader>os", function()
      require("opencode").select()
    end, { desc = "Select prompt" })
    vim.keymap.set("n", "<leader>ot", function()
      require("opencode").toggle()
    end, { desc = "Toggle embedded" })
    vim.keymap.set("n", "<leader>on", function()
      require("opencode").command("session.new")
    end, { desc = "New session" })
    vim.keymap.set("n", "<leader>oi", function()
      require("opencode").command("session.interrupt")
    end, { desc = "Interrupt session" })
    vim.keymap.set("n", "<S-C-u>", function()
      require("opencode").command("messages_half_page_up")
    end, { desc = "Messages half page up" })
    vim.keymap.set("n", "<S-C-d>", function()
      require("opencode").command("messages_half_page_down")
    end, { desc = "Messages half page down" }) -- Custom commands
    vim.keymap.set("n", "<leader>oc", function()
      require("opencode").prompt(
        "Look at the branch name to get the Linear ticket, and then use the commit skill to commit the staged code",
        { submit = true }
      )
    end, { desc = "Commit changes" })
    vim.keymap.set("n", "<leader>oC", function()
      require("opencode").prompt(
        'Look at the branch name to get the Linear ticket, then commit any staged changes we have using the commit skill. Rebase the current branch with master and use the pr skill to create a PR. After it, using the google workspace mcp, send a message to the channel "Performance Team Chat" (spaces/AAQAPypdP5c) with the link and a one line description.',
        { submit = true }
      )
    end, { desc = "Create an PR" })
  end,
}
