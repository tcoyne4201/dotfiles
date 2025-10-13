#!/bin/bash

echo "=== Testing Ruff Configuration ==="
echo

# Check if ruff is available
if ! command -v ruff &> /dev/null; then
    echo "❌ Ruff not found in PATH"
    exit 1
fi

echo "✅ Ruff version: $(ruff --version)"
echo

# Check if pyproject.toml exists
if [ ! -f "pyproject.toml" ]; then
    echo "❌ pyproject.toml not found in current directory"
    echo "Current directory: $(pwd)"
    exit 1
fi

echo "✅ Found pyproject.toml"
echo "Content:"
cat pyproject.toml
echo

# Test ruff configuration
echo "=== Testing Ruff Configuration Reading ==="
echo "Ruff configuration that will be used:"
ruff check --show-settings . 2>/dev/null || echo "Could not show settings"
echo

# Test the long line file
if [ -f "test_line_length.py" ]; then
    echo "=== Testing Line Length on test_line_length.py ==="
    echo "Running ruff check:"
    ruff check test_line_length.py --select E501 || echo "No E501 (line too long) errors found"
    echo
    
    echo "Running ruff check with verbose output:"
    ruff check test_line_length.py --verbose --select E501 || echo "No E501 errors with verbose output"
else
    echo "❌ test_line_length.py not found"
fi

echo
echo "=== Summary ==="
echo "If you're still seeing line length errors in Neovim:"
echo "1. Restart Neovim: the LSP might be cached"
echo "2. Run :LspRestart in Neovim"
echo "3. Check that you're in the same directory as pyproject.toml"
echo "4. Verify no other linting tools are running"
