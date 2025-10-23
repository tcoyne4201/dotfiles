-- Custom options
-- Additional options beyond the default kickstart ones

local opt = vim.opt

-- Line wrapping
opt.wrap = false -- Display lines as one long line
opt.linebreak = true -- Companion to wrap, don't split words

-- Tabs & indentation
opt.expandtab = true -- Use spaces instead of tabs
opt.shiftwidth = 2 -- Size of an indent
opt.tabstop = 2 -- Number of spaces tabs count for

-- Search settings
opt.ignorecase = true -- Ignore case
opt.smartcase = true -- Don't ignore case with capitals

-- Appearance
opt.termguicolors = true -- True color support
opt.signcolumn = 'yes' -- Always show the signcolumn
opt.cmdheight = 1 -- More space in the neovim command line for displaying messages

-- Behavior
opt.hidden = true -- Enable modified buffers in background
opt.errorbells = false -- Disable error bells
opt.swapfile = false -- Don't use swapfile
opt.backup = false -- Don't create backup files
opt.writebackup = false -- Don't create backup files
opt.undofile = true -- Save undo history
opt.undodir = vim.fn.expand '~/.vim/undodir' -- Set undodir

-- Completion
opt.completeopt = { 'menuone', 'noselect' } -- Completion options
opt.shortmess:append 'c' -- Don't give completion messages

-- Performance
opt.updatetime = 250 -- Faster completion (4000ms default)
opt.timeoutlen = 300 -- Time to wait for a mapped sequence to complete (in milliseconds)

-- Splits
opt.splitbelow = true -- Put new windows below current
opt.splitright = true -- Put new windows right of current

-- Wild menu
opt.wildmode = 'longest:full,full' -- Command-line completion mode
opt.wildignore:append { '*.o', '*.obj', '.git', '*.rbc', '*.pyc', '__pycache__' }

-- Diff
opt.diffopt:append 'linematch:60' -- Enable linematch diff algorithm
