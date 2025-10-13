#!/usr/bin/env python3
"""Test file to check line length linting."""

# This line should be fine with default settings (under 88 characters)
def short_function():
    return "This is a short line"

# This line is intentionally long to test line length settings - it should trigger a warning if line-length is set to something shorter than this line
def very_long_function_name_that_exceeds_normal_line_length_limits():
    return "This function name and line is intentionally very long to test line length linting configuration"

# Another long line for testing
result = very_long_function_name_that_exceeds_normal_line_length_limits() + " and some additional text to make it even longer"

print("Test file for line length linting - check diagnostics with <leader>sd")
