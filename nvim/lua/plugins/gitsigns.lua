return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPost", "BufWritePost", "BufNewFile" },
  opts = {
    signs = {
      add = { text = "▎" },
      change = { text = "▎" },
      delete = { text = "" },
      topdelete = { text = "" },
      changedelete = { text = "▎" },
      untracked = { text = "▎" },
    },
    signs_staged = {
      add = { text = "▎" },
      change = { text = "▎" },
      delete = { text = "" },
      topdelete = { text = "" },
      changedelete = { text = "▎" },
    },
    on_attach = function(buffer)
      local gs = package.loaded.gitsigns

      local function map(mode, l, r, desc)
        vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
      end

      map("n", "]h", function()
        if vim.wo.diff then
          vim.cmd.normal({ "]c", bang = true })
        else
          gs.nav_hunk("next")
        end
      end, "Next Hunk")

      map("n", "[h", function()
        if vim.wo.diff then
          vim.cmd.normal({ "[c", bang = true })
        else
          gs.nav_hunk("prev")
        end
      end, "Previous Hunk")

      -- Navigation
      map("n", "]c", function()
        if vim.wo.diff then
          vim.cmd.normal({ "]c", bang = true })
        else
          gs.nav_hunk("next")
        end
      end, "Next Hunk")

      map("n", "[c", function()
        if vim.wo.diff then
          vim.cmd.normal({ "[c", bang = true })
        else
          gs.nav_hunk("prev")
        end
      end, "Previous Hunk")

      -- Actions
      map("n", "<leader>hs", gs.stage_hunk, "Stage Hunk")
      map("n", "<leader>hr", gs.reset_hunk, "Reset Hunk")

      map("v", "<leader>hs", function()
        gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
      end, "Stage Hunk")

      map("v", "<leader>hr", function()
        gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
      end, "Reset Hunk")

      map("n", "<leader>hS", gs.stage_buffer, "Stage Buffer")
      map("n", "<leader>hR", gs.reset_buffer, "Reset Buffer")
      map("n", "<leader>hp", gs.preview_hunk, "Preview Hunk")
      map("n", "<leader>hi", gs.preview_hunk_inline, "Preview Hunk Inline")

      map("n", "<leader>hb", function()
        gs.blame_line({ full = true })
      end, "Blame Line")

      map("n", "<leader>hd", gs.diffthis, "Diff This")

      map("n", "<leader>hD", function()
        gs.diffthis("~")
      end, "Diff All")

      map("n", "<leader>hQ", function()
        gs.setqflist("all")
      end, "Quickfix List All")
      map("n", "<leader>hq", gs.setqflist, "Quickfix List")

      -- Toggles
      map("n", "<leader>tb", gs.toggle_current_line_blame, "Toggle Blame")
      map("n", "<leader>td", gs.toggle_deleted, "Toggle Deleted")
      map("n", "<leader>tw", gs.toggle_word_diff, "Toggle Word Diff")

      -- Text object
      map({ "o", "x" }, "ih", gs.select_hunk, "Select Hunk")
    end,
  },
}
