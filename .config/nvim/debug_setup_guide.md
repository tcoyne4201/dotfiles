# Python Debugging Setup with uv Integration

Your Neovim debug configuration has been updated to seamlessly work with uv virtual environments!

## How It Works

The debug.lua file now:

1. **Automatically detects your project's Python interpreter** using the same logic as the LSP
2. **Uses `uv python find`** for uv projects to get the correct Python path
3. **Falls back to traditional venv detection** (.venv, venv, VIRTUAL_ENV)
4. **Configures nvim-dap-python** with the detected interpreter
5. **Checks for debugpy availability** and warns if it's missing

## Setup Instructions

### 1. Add debugpy to your uv projects

For each Python project where you want debugging:

```bash
cd your-python-project
uv add --dev debugpy
```

Or add it to your pyproject.toml:

```toml
[project.optional-dependencies]
dev = [
    "debugpy",
    "python-lsp-server[all]",
    "ruff",
]
```

Then run: `uv sync --dev`

### 2. Debug Key Bindings

The following keybindings are available:

- `<F5>` - Start/Continue debugging
- `<F1>` - Step Into
- `<F2>` - Step Over  
- `<F3>` - Step Out
- `<F7>` - Toggle Debug UI
- `<leader>b` - Toggle Breakpoint
- `<leader>B` - Set Conditional Breakpoint

### 3. Usage Example

1. Create a test Python file:
```python
def fibonacci(n):
    if n <= 1:
        return n
    return fibonacci(n-1) + fibonacci(n-2)

def main():
    for i in range(10):
        result = fibonacci(i)
        print(f"fibonacci({i}) = {result}")

if __name__ == "__main__":
    main()
```

2. Open the file in Neovim: `nvim test_debug.py`
3. Set a breakpoint on line 6: place cursor and press `<leader>b`
4. Start debugging: press `<F5>`
5. The debugger will use your project's virtual environment automatically!

## Troubleshooting

### If debugpy is missing:
You'll see a warning. Install it with:
```bash
uv add --dev debugpy
```

### If debugging doesn't start:
1. Check that you're in a Python file (`:echo &filetype` should show "python")
2. Verify your virtual environment has debugpy installed
3. Check `:checkhealth` for any DAP-related issues

### Manual Python path override:
If you need to manually set the Python path for debugging:
```lua
require('dap-python').setup('/path/to/your/python')
```

## Features

✅ **Automatic uv project detection**  
✅ **Dynamic Python interpreter selection**  
✅ **Virtual environment isolation**  
✅ **Seamless project switching**  
✅ **Debugpy availability checking**  
✅ **Integration with existing LSP setup**

The debugging setup now works seamlessly with your uv workflow!
