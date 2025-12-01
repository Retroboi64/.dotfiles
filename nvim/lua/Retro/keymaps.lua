local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Clear search highlighting
keymap('n', '<Esc>', '<cmd>nohlsearch<CR>', opts)

-- Better window navigation
keymap('n', '<C-h>', '<C-w>h', opts)
keymap('n', '<C-j>', '<C-w>j', opts)
keymap('n', '<C-k>', '<C-w>k', opts)
keymap('n', '<C-l>', '<C-w>l', opts)

-- Resize windows
keymap('n', '<C-Up>', ':resize +2<CR>', opts)
keymap('n', '<C-Down>', ':resize -2<CR>', opts)
keymap('n', '<C-Left>', ':vertical resize -2<CR>', opts)
keymap('n', '<C-Right>', ':vertical resize +2<CR>', opts)

-- Buffer navigation
keymap('n', '<S-l>', ':bnext<CR>', opts)
keymap('n', '<S-h>', ':bprevious<CR>', opts)
keymap('n', '<leader>x', ':bdelete<CR>', opts)

-- Move lines
keymap('n', '<A-j>', ':m .+1<CR>==', opts)
keymap('n', '<A-k>', ':m .-2<CR>==', opts)
keymap('v', '<A-j>', ":m '>+1<CR>gv=gv", opts)
keymap('v', '<A-k>', ":m '<-2<CR>gv=gv", opts)

-- Better indenting
keymap('v', '<', '<gv', opts)
keymap('v', '>', '>gv', opts)

-- File explorer (Oil)
keymap('n', '<leader>e', '<cmd>Oil<CR>', opts)

-- Telescope keymaps
keymap('n', '<leader>ff', ':Telescope find_files<CR>', opts)
keymap('n', '<leader>fg', ':Telescope live_grep<CR>', opts)
keymap('n', '<leader>fb', ':Telescope buffers<CR>', opts)
keymap('n', '<leader>fh', ':Telescope help_tags<CR>', opts)
keymap('n', '<leader>fc', ':Telescope grep_string<CR>', opts)
keymap('n', '<leader>fr', ':Telescope lsp_references<CR>', opts)

-- Hop for faster movement
keymap('n', 'f', ':HopChar1<CR>', opts)
keymap('n', 'F', ':HopChar1AC<CR>', opts)
keymap('n', 's', ':HopChar2<CR>', opts)

-- LSP
keymap('n', 'gd', vim.lsp.buf.definition, opts)
keymap('n', 'gD', vim.lsp.buf.declaration, opts)
keymap('n', 'gi', vim.lsp.buf.implementation, opts)
keymap('n', 'gr', vim.lsp.buf.references, opts)
keymap('n', 'K', vim.lsp.buf.hover, opts)
keymap('n', '<leader>rn', vim.lsp.buf.rename, opts)
keymap('n', '<leader>ca', vim.lsp.buf.code_action, opts)
keymap('n', '[d', vim.diagnostic.goto_prev, opts)
keymap('n', ']d', vim.diagnostic.goto_next, opts)
keymap('n', '<leader>d', vim.diagnostic.open_float, opts)

-- Save
keymap('n', '<C-s>', ':w<CR>', opts)
keymap('i', '<C-s>', '<Esc>:w<CR>a', opts)

-- Quit
keymap('n', '<leader>q', ':q<CR>', opts)
keymap('n', '<leader>Q', ':qa!<CR>', opts)

-- Split windows
keymap('n', '<leader>sv', ':vsplit<CR>', opts)
keymap('n', '<leader>sh', ':split<CR>', opts)

-- CMake commands
keymap('n', '<leader>cg', ':CMakeGenerate<CR>', opts)
keymap('n', '<leader>cb', ':CMakeBuild<CR>', opts)
keymap('n', '<leader>cr', ':CMakeRun<CR>', opts)
keymap('n', '<leader>cd', ':CMakeDebug<CR>', opts)
keymap('n', '<leader>cc', ':CMakeClean<CR>', opts)
keymap('n', '<leader>ct', ':CMakeSelectBuildType<CR>', opts)

-- Debugging
keymap('n', '<leader>db', ':DapToggleBreakpoint<CR>', opts)
keymap('n', '<leader>dc', ':DapContinue<CR>', opts)
keymap('n', '<leader>di', ':DapStepInto<CR>', opts)
keymap('n', '<leader>do', ':DapStepOver<CR>', opts)
keymap('n', '<leader>dO', ':DapStepOut<CR>', opts)
keymap('n', '<leader>dr', ':DapToggleRepl<CR>', opts)
keymap('n', '<leader>dt', ':DapTerminate<CR>', opts)

-- Quick compile and run
keymap('n', '<F5>', ':CMakeBuild<CR>:CMakeRun<CR>', opts)
keymap('n', '<F6>', ':CMakeDebug<CR>', opts)

-- Grug-far (find and replace)
keymap('n', '<leader>sr', ':GrugFar<CR>', opts)

-- Session management
keymap('n', '<leader>ss', function() require('persistence').save() end, opts)
keymap('n', '<leader>sl', function() require('persistence').load() end, opts)

vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank({ timeout = 200 })
  end,
})

vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = '*',
  callback = function()
    local save_cursor = vim.fn.getpos('.')
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.setpos('.', save_cursor)
  end,
})

vim.api.nvim_create_autocmd('BufReadPost', {
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    if mark[1] > 1 and mark[1] <= vim.api.nvim_buf_line_count(0) then
      vim.api.nvim_win_set_cursor(0, mark)
    end
  end,
})

vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = { '*.cpp', '*.h', '*.hpp', '*.c' },
  callback = function()
    vim.lsp.buf.format({ async = false })
  end,
})

