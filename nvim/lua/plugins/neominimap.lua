return ---@module "neominimap.config.meta"
{
  "Isrothy/neominimap.nvim",
  version = "v3.x.x",
  lazy = false, -- NOTE: NO NEED to Lazy load
  -- Optional. You can alse set your own keybindings
  keys = {
    -- Global Minimap Controls
    { "<leader>nm", "<cmd>Neominimap toggle<cr>", desc = "Toggle global minimap" },
    { "<leader>no", "<cmd>Neominimap on<cr>", desc = "Enable global minimap" },
    { "<leader>nc", "<cmd>Neominimap off<cr>", desc = "Disable global minimap" },
    { "<leader>nr", "<cmd>Neominimap refresh<cr>", desc = "Refresh global minimap" },

    -- Window-Specific Minimap Controls
    { "<leader>nwt", "<cmd>Neominimap winToggle<cr>", desc = "Toggle minimap for current window" },
    { "<leader>nwr", "<cmd>Neominimap winRefresh<cr>", desc = "Refresh minimap for current window" },
    { "<leader>nwo", "<cmd>Neominimap winOn<cr>", desc = "Enable minimap for current window" },
    { "<leader>nwc", "<cmd>Neominimap winOff<cr>", desc = "Disable minimap for current window" },

    -- Tab-Specific Minimap Controls
    { "<leader>ntt", "<cmd>Neominimap tabToggle<cr>", desc = "Toggle minimap for current tab" },
    { "<leader>ntr", "<cmd>Neominimap tabRefresh<cr>", desc = "Refresh minimap for current tab" },
    { "<leader>nto", "<cmd>Neominimap tabOn<cr>", desc = "Enable minimap for current tab" },
    { "<leader>ntc", "<cmd>Neominimap tabOff<cr>", desc = "Disable minimap for current tab" },

    -- Buffer-Specific Minimap Controls
    { "<leader>nbt", "<cmd>Neominimap bufToggle<cr>", desc = "Toggle minimap for current buffer" },
    { "<leader>nbr", "<cmd>Neominimap bufRefresh<cr>", desc = "Refresh minimap for current buffer" },
    { "<leader>nbo", "<cmd>Neominimap bufOn<cr>", desc = "Enable minimap for current buffer" },
    { "<leader>nbc", "<cmd>Neominimap bufOff<cr>", desc = "Disable minimap for current buffer" },

    ---Focus Controls
    { "<leader>nf", "<cmd>Neominimap focus<cr>", desc = "Focus on minimap" },
    { "<leader>nu", "<cmd>Neominimap unfocus<cr>", desc = "Unfocus minimap" },
    { "<leader>ns", "<cmd>Neominimap toggleFocus<cr>", desc = "Switch focus on minimap" },
  },
  init = function()
    -- The following options are recommended when layout == "float"
    vim.opt.wrap = false
    vim.opt.sidescrolloff = 40 -- Set a large value

    --- Put your configuration here
    ---@type Neominimap.UserConfig
    vim.g.neominimap = {
      auto_enable = true,
      y_multiplier = 4,
      exclude_buftypes = {
        "acwrite",
        "nofile",
        "nowrite",
        "quickfix",
        "terminal",
        "prompt",
      },
      float = {
        window_border = vim.fn.has("nvim-0.11") == 1 and vim.o.winborder or "single",
      },
      winopt = function(opt, winid)
        opt.winfixwidth = false
        vim.schedule(function()
          if not vim.api.nvim_win_is_valid(winid) then
            return
          end
          local window_map = require("neominimap.window.float.window_map")
          local mwinid = window_map.get_minimap_winid(winid)
          if not mwinid or not vim.api.nvim_win_is_valid(mwinid) then
            return
          end
          local src_width = vim.api.nvim_win_get_width(winid)
          local new_width = math.max(1, src_width - 20)
          local cfg = vim.api.nvim_win_get_config(mwinid)
          cfg.width = new_width
          vim.api.nvim_win_set_config(mwinid, cfg)
        end)
      end,
    }
  end,
}
