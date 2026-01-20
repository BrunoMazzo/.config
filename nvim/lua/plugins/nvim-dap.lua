return {
  "mfussenegger/nvim-dap",
  desc = "Debugging support. Requires language specific adapters to be configured. (see lang extras)",

  dependencies = {
    "rcarriga/nvim-dap-ui",
    -- virtual text for the debugger
    {
      "theHamsta/nvim-dap-virtual-text",

      opts = {},
    },
    { "jay-babu/mason-nvim-dap.nvim" },
    -- {"jay-babu/mason-nvim-dap.nvim",},
  },

  -- stylua: ignore
  keys = {
    { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, desc = "Breakpoint Condition" },
    { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
    { "<leader>dc", function() require("dap").continue() end, desc = "Run/Continue" },
    { "<leader>da", function() require("dap").continue({ before = get_args }) end, desc = "Run with Args" },
    { "<leader>dC", function() require("dap").run_to_cursor() end, desc = "Run to Cursor" },
    { "<leader>dg", function() require("dap").goto_() end, desc = "Go to Line (No Execute)" },
    { "<leader>di", function() require("dap").step_into() end, desc = "Step Into" },
    { "<leader>dj", function() require("dap").down() end, desc = "Down" },
    { "<leader>dk", function() require("dap").up() end, desc = "Up" },
    { "<leader>dl", function() require("dap").run_last() end, desc = "Run Last" },
    { "<leader>do", function() require("dap").step_out() end, desc = "Step Out" },
    { "<leader>dO", function() require("dap").step_over() end, desc = "Step Over" },
    { "<leader>dP", function() require("dap").pause() end, desc = "Pause" },
    { "<leader>dr", function() require("dap").repl.toggle() end, desc = "Toggle REPL" },
    { "<leader>ds", function() require("dap").session() end, desc = "Session" },
    { "<leader>dt", function() require("dap").terminate() end, desc = "Terminate" },
    { "<leader>dw", function() require("dap.ui.widgets").hover() end, desc = "Widgets" },
  },

  config = function()
    vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })

    -- local js_based_languages = {
    --   "typescript",
    --   "javascript",
    --   "typescriptreact",
    --   "javascriptreact",
    --   "vue",
    -- }
    -- local dap = require("dap")

    
    -- local dapDebugServerJsPath = vim.fn.exepath("js-debug-adapter")
      -- .. "/js-debug/src/dapDebugServer.js"

    for _, adapter in pairs({ "pwa-node", "pwa-chrome" }) do
    require("dap").adapters[adapter] = {
        type = "server",
        host = "localhost",
        port = "${port}",
        executable = {
            command = "js-debug-adapter",
            args = { "${port}" },
        },
    }
end
    -- dap.adapters["pwa-node"] = {
      -- type = "server",
      -- host = "localhost",
      -- port = "${port}",
      -- executable = {
        -- command = "node",
        -- 💀 Make sure to update this path to point to your installation
        -- args = { dapDebugServerJsPath, "${port}" },
        -- args = { "${port}" },
      -- },
    -- }

    -- dap.adapters["pwa-chrome"] = {
    --   type = "server",
    --   host = "localhost",
    --   port = "${port}",
    --   executable = {
    --     command = "node",
    --     args = {
    --       dapDebugServerJsPath,
    --       "${port}",
    --     },
    --   },
    -- }
    --
    -- for _, language in ipairs(js_based_languages) do
    --   dap.configurations[language] = {
    --     -- Debug single nodejs files
    --     {
    --       type = "pwa-node",
    --       request = "launch",
    --       name = "Launch file",
    --       program = "${file}",
    --       cwd = vim.fn.getcwd(),
    --       sourceMaps = true,
    --     },
    --     -- Debug nodejs processes (make sure to add --inspect when you run the process)
    --     {
    --       type = "pwa-node",
    --       request = "attach",
    --       name = "Attach",
    --       processId = require("dap.utils").pick_process,
    --       cwd = vim.fn.getcwd(),
    --       sourceMaps = true,
    --     },
    --     -- Debug web applications (client side)
    --     {
    --       type = "pwa-chrome",
    --       request = "launch",
    --       name = "Launch & Debug Chrome",
    --       -- url = function()
    --       --   local co = coroutine.running()
    --       --   return coroutine.create(function()
    --       --     vim.ui.input({
    --       --       prompt = "Enter URL: ",
    --       --       default = "http://localhost:3000",
    --       --     }, function(url)
    --       --       if url == nil or url == "" then
    --       --         return
    --       --       else
    --       --         coroutine.resume(co, url)
    --       --       end
    --       --     end)
    --       --   end)
    --       -- end,
    --       url = "http://localhost:1234",
    --       webRoot = vim.fn.getcwd(),
    --       protocol = "inspector",
    --       -- sourceMaps = true,
    --       -- webRoot = "${workspaceFolder}",
    --       -- breakOnLoad = true,
    --       -- sourceMapPathOverrides = {
    --         -- ["/__parcel_source_root/*"] = "${webRoot}/*",
    --       -- },
    --       -- userDataDir = false,
    --     },
    --     -- Divider for the launch.json derived configs
    --     {
    --       name = "----- ↓ launch.json configs ↓ -----",
    --       type = "",
    --       request = "launch",
    --     },
    --   }
    -- end
  end,
}
