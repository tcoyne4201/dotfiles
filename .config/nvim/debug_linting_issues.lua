-- Debug script to help identify linting issues
-- Run this in Neovim with :luafile debug_linting_issues.lua

local function debug_linting_setup()
  print("=== Python Linting Debug Information ===")
  print()
  
  -- Check current buffer filetype
  local filetype = vim.bo.filetype
  print("Current filetype: " .. filetype)
  
  if filetype ~= "python" then
    print("⚠️  Not in a Python file. Open a .py file first.")
    return
  end
  
  -- Check active LSP clients
  print("\n--- Active LSP Clients ---")
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients == 0 then
    print("❌ No LSP clients attached to current buffer")
  else
    for _, client in ipairs(clients) do
      print("✅ " .. client.name .. " (ID: " .. client.id .. ")")
      
      -- Show client settings for ruff and pylsp
      if client.name == "ruff" then
        print("   Ruff settings:")
        if client.config.init_options and client.config.init_options.settings then
          for k, v in pairs(client.config.init_options.settings) do
            print("     " .. k .. ": " .. vim.inspect(v))
          end
        else
          print("     No init_options.settings found")
        end
      elseif client.name == "pylsp" then
        print("   Pylsp settings:")
        if client.config.settings and client.config.settings.pylsp then
          print("     plugins:")
          for k, v in pairs(client.config.settings.pylsp.plugins or {}) do
            print("       " .. k .. ": " .. vim.inspect(v))
          end
        end
      end
    end
  end
  
  -- Check current working directory and project root
  print("\n--- Project Information ---")
  print("Current working directory: " .. vim.fn.getcwd())
  
  local current_file = vim.fn.expand('%:p')
  print("Current file: " .. current_file)
  
  -- Check for configuration files
  local config_files = {
    "pyproject.toml",
    "setup.cfg", 
    ".flake8",
    "tox.ini",
    "ruff.toml"
  }
  
  print("\n--- Configuration Files ---")
  for _, file in ipairs(config_files) do
    if vim.fn.filereadable(file) == 1 then
      print("✅ Found: " .. file)
      if file == "pyproject.toml" then
        -- Try to read line-length from pyproject.toml
        local content = vim.fn.readfile(file)
        for _, line in ipairs(content) do
          if line:match("line%-length") then
            print("   " .. line)
          end
        end
      end
    else
      print("❌ Not found: " .. file)
    end
  end
  
  -- Check diagnostics
  print("\n--- Current Diagnostics ---")
  local diagnostics = vim.diagnostic.get(0)
  if #diagnostics == 0 then
    print("✅ No diagnostics in current buffer")
  else
    print("Found " .. #diagnostics .. " diagnostics:")
    for i, diag in ipairs(diagnostics) do
      local source = diag.source or "unknown"
      local message = diag.message or "no message"
      print(string.format("  %d. [%s] Line %d: %s", i, source, diag.lnum + 1, message))
    end
  end
  
  -- Check if ruff is available
  print("\n--- Tool Availability ---")
  local ruff_available = vim.fn.executable("ruff") == 1
  print("Ruff executable: " .. (ruff_available and "✅ Available" or "❌ Not found"))
  
  if ruff_available then
    local ruff_version = vim.fn.system("ruff --version"):gsub("\n", "")
    print("Ruff version: " .. ruff_version)
    
    -- Check ruff config
    local ruff_config = vim.fn.system("ruff check --show-settings 2>/dev/null"):gsub("\n", "")
    if ruff_config ~= "" then
      print("Ruff is reading configuration")
    end
  end
  
  print("\n=== Debug Complete ===")
  print("If you're still seeing pycodestyle errors:")
  print("1. Make sure only one of pylsp or ruff is handling linting")
  print("2. Check that your pyproject.toml is in the project root")
  print("3. Restart Neovim after configuration changes")
  print("4. Use :LspRestart to reload LSP servers")
end

-- Run the debug function
debug_linting_setup()
