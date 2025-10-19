-- debug.lua
--
-- Shows how to use the DAP plugin to debug your code.
--
-- Primarily focused on configuring the debugger for Go, but can
-- be extended to other languages as well. That's why it's called
-- kickstart.nvim and not kitchen-sink.nvim ;)

return {
  -- NOTE: Yes, you can install new plugins here!
  'mfussenegger/nvim-dap',
  -- NOTE: And you can specify dependencies as well
  dependencies = {
    -- Creates a beautiful debugger UI
    'rcarriga/nvim-dap-ui',

    -- Required dependency for nvim-dap-ui
    'nvim-neotest/nvim-nio',

    -- Installs the debug adapters for you
    'mason-org/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',

    -- Add your own debuggers here
    'leoluz/nvim-dap-go',
    -- Python debugger
    'mfussenegger/nvim-dap-python',
  },
  keys = {
    -- Basic debugging keymaps, feel free to change to your liking!
    {
      '<F5>',
      function()
        require('dap').continue()
      end,
      desc = 'Debug: Start/Continue',
    },
    {
      '<F1>',
      function()
        require('dap').step_into()
      end,
      desc = 'Debug: Step Into',
    },
    {
      '<F2>',
      function()
        require('dap').step_over()
      end,
      desc = 'Debug: Step Over',
    },
    {
      '<F3>',
      function()
        require('dap').step_out()
      end,
      desc = 'Debug: Step Out',
    },
    {
      '<leader>b',
      function()
        require('dap').toggle_breakpoint()
      end,
      desc = 'Debug: Toggle Breakpoint',
    },
    {
      '<leader>B',
      function()
        require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ')
      end,
      desc = 'Debug: Set Breakpoint',
    },
    -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
    {
      '<F7>',
      function()
        require('dapui').toggle()
      end,
      desc = 'Debug: See last session result.',
    },
  },
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'

    require('mason-nvim-dap').setup {
      -- Makes a best effort to setup the various debuggers with
      -- reasonable debug configurations
      automatic_installation = true,

      -- You can provide additional configuration to the handlers,
      -- see mason-nvim-dap README for more information
      handlers = {},

      -- You'll need to check that you have the required things installed
      -- online, please don't ask me how to install them :)
      ensure_installed = {
        -- Update this to ensure that you have the debuggers for the langs you want
        'delve',
        'debugpy', -- Python debugger (will also be installed in project venvs)
      },
    }

    -- Dap UI setup
    -- For more information, see |:help nvim-dap-ui|
    dapui.setup {
      -- Set icons to characters that are more likely to work in every terminal.
      --    Feel free to remove or use ones that you like more! :)
      --    Don't feel like these are good choices.
      icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
      controls = {
        icons = {
          pause = '⏸',
          play = '▶',
          step_into = '⏎',
          step_over = '⏭',
          step_out = '⏮',
          step_back = 'b',
          run_last = '▶▶',
          terminate = '⏹',
          disconnect = '⏏',
        },
      },
    }

    -- Change breakpoint icons
    vim.api.nvim_set_hl(0, 'DapBreak', { fg = '#e51400' })
    vim.api.nvim_set_hl(0, 'DapStop', { fg = '#ffcc00' })
    local breakpoint_icons = vim.g.have_nerd_font
        and { Breakpoint = '', BreakpointCondition = '', BreakpointRejected = '', LogPoint = '', Stopped = '' }
      or { Breakpoint = '●', BreakpointCondition = '⊜', BreakpointRejected = '⊘', LogPoint = '◆', Stopped = '⭔' }
    for type, icon in pairs(breakpoint_icons) do
      local tp = 'Dap' .. type
      local hl = (type == 'Stopped') and 'DapStop' or 'DapBreak'
      vim.fn.sign_define(tp, { text = icon, texthl = hl, numhl = hl })
    end

    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    dap.listeners.before.event_exited['dapui_config'] = dapui.close

    -- Install golang specific config
    require('dap-go').setup {
      delve = {
        -- On Windows delve must be run attached or it crashes.
        -- See https://github.com/leoluz/nvim-dap-go/blob/main/README.md#configuring
        detached = vim.fn.has 'win32' == 0,
      },
    }

    -- Python debugging setup with uv virtual environment support
    local function setup_python_debugging()
      -- Import the same helper functions from init.lua
      local function project_root(fname)
        local start = vim.fs.dirname(fname)
        -- Prefer common Python project files (uv projects use pyproject.toml)
        local root_files = { 'pyproject.toml', 'uv.lock', 'setup.py', 'setup.cfg', 'requirements.txt', 'Pipfile' }
        local root_file = vim.fs.find(root_files, { path = start, upward = true })[1]
        if root_file then
          return vim.fs.dirname(root_file)
        end
        -- Fallback to git root
        local git = vim.fs.find('.git', { path = start, upward = true })[1]
        if git then
          return vim.fs.dirname(git)
        end
        -- Last resort: the directory of the file
        return start
      end

      local function find_python_executable(root_dir)
        local join = function(...)
          return table.concat({ ... }, '/')
        end

        -- First, try uv if available and this is a uv project
        if vim.fn.executable 'uv' == 1 then
          local pyproject = join(root_dir, 'pyproject.toml')
          local uv_lock = join(root_dir, 'uv.lock')

          if vim.fn.filereadable(pyproject) == 1 or vim.fn.filereadable(uv_lock) == 1 then
            -- This looks like a uv project, try to get the python path from uv
            local result = vim.fn.system('cd ' .. vim.fn.shellescape(root_dir) .. ' && uv python find 2>/dev/null')
            if vim.v.shell_error == 0 and result and result:match '%S' then
              local python_path = result:gsub('%s+$', '') -- trim whitespace
              if vim.fn.executable(python_path) == 1 then
                return python_path
              end
            end
          end
        end

        -- Fallback to traditional venv detection
        local candidates = {
          join(root_dir, '.venv/bin/python'),
          join(root_dir, 'venv/bin/python'),
        }

        -- Check VIRTUAL_ENV if set
        if vim.env.VIRTUAL_ENV then
          table.insert(candidates, 1, join(vim.env.VIRTUAL_ENV, 'bin/python'))
        end

        for _, python_path in ipairs(candidates) do
          if vim.fn.executable(python_path) == 1 then
            return python_path
          end
        end

        -- Final fallback to system python
        return 'python3'
      end

      -- Get the current file and determine the Python executable
      local current_file = vim.fn.expand '%:p'
      local root_dir = current_file and current_file ~= '' and project_root(current_file) or vim.fn.getcwd()
      local python_path = find_python_executable(root_dir)

      -- Setup nvim-dap-python with the detected Python executable
      require('dap-python').setup(python_path)

      -- Ensure debugpy is available in the virtual environment
      local function ensure_debugpy()
        if python_path and python_path ~= 'python3' then
          local check_cmd = string.format('%s -c "import debugpy" 2>/dev/null', vim.fn.shellescape(python_path))
          local result = vim.fn.system(check_cmd)
          if vim.v.shell_error ~= 0 then
            vim.notify(
              string.format('debugpy not found in virtual environment (%s). Install it with: %s -m pip install debugpy', python_path, python_path),
              vim.log.levels.WARN
            )
          end
        end
      end

      ensure_debugpy()
    end

    -- Setup Python debugging when entering Python files
    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'python',
      callback = setup_python_debugging,
      desc = 'Setup Python debugging with project virtual environment',
    })

    -- Also setup immediately if we're already in a Python file
    if vim.bo.filetype == 'python' then
      setup_python_debugging()
    end
  end,
}
