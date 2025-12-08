local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git', 'clone', '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  -- Color scheme
  {
    'ellisonleao/gruvbox.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      require('gruvbox').setup({
        contrast = 'hard',
        transparent_mode = false,
      })
      vim.cmd.colorscheme('gruvbox')
      vim.o.background = 'dark'
    end,
  },

  -- Fuzzy finder
  {
    'nvim-telescope/telescope.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('telescope').setup({
        defaults = {
          mappings = {
            i = {
              ['<C-j>'] = 'move_selection_next',
              ['<C-k>'] = 'move_selection_previous',
            },
          },
          layout_strategy = 'vertical',
          layout_config = { height = 0.9, width = 0.9 },
        },
      })
    end,
  },

  -- File explorer
  {
    'stevearc/oil.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
    require("oil").setup({
        default_file_explorer = true,
        columns = { "icon" },

        view_options = {
            show_hidden = false,
            natural_order = true,
        },

        keymaps = {
            ["<CR>"] = "actions.select",
            ["<C-s>"] = { "actions.select", opts = { vertical = true }},
            ["<C-h>"] = { "actions.select", opts = { horizontal = true }},
            ["<C-t>"] = { "actions.select", opts = { tab = true }},
            ["g?"] = "actions.show_help",

            -- TODO
            ["~"] = {"actions.cd", mode="n"},
            ["<Esc>"] = "actions.close",
            ["<BS>"] = "actions.parent",
            ["g."] = "actions.toggle_hidden",
            ["<C-p>"] = "actions.preview",
            ["<C-l>"] = "actions.refresh",
        },

        float = {
            padding = 2,
            max_width = 0.9,
            max_height = 0.9,
            border = "rounded",
        },

        preview_win = {
            update_on_cursor_moved = true,
        },
    })
    end,
  },

  -- Statusline
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('lualine').setup({
        options = {
          theme = 'gruvbox',
          component_separators = '|',
          section_separators = '',
        },
        sections = {
          lualine_c = { { 'filename', path = 1 } },
        },
      })
    end,
  },

  -- Treesitter for syntax highlighting
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter.configs').setup({
        ensure_installed = { 'c', 'cpp', 'cmake', 'make', 'lua', 'vim', 'glsl', 'json', 'yaml' },
        auto_install = true,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        indent = { enable = true },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = '<C-space>',
            node_incremental = '<C-space>',
            node_decremental = '<C-backspace>',
          },
        },
      })
    end,
  },

  -- LSP Configuration
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      'hrsh7th/cmp-nvim-lsp',
      'folke/neodev.nvim',
    },
    config = function()
      require('mason').setup()
      require('neodev').setup()
      require('mason-lspconfig').setup({
        ensure_installed = { 'clangd', 'cmake', 'lua_ls' },
        automatic_installation = true,
      })

      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      vim.lsp.config('clangd', {
        capabilities = capabilities,
        cmd = {
          'clangd',
          '--background-index',
          '--clang-tidy',
          '--clang-tidy-checks=*',
          '--header-insertion=iwyu',
          '--completion-style=detailed',
          '--function-arg-placeholders',
          '--fallback-style=llvm',
          '--malloc-trim',
          '--pch-storage=memory',
        },
        filetypes = { 'c', 'cpp', 'objc', 'objcpp' },
        root_markers = { 'compile_commands.json', '.git', 'CMakeLists.txt' },
        on_attach = function(client, bufnr)
          client.server_capabilities.semanticTokensProvider = nil
        end,
      })

      vim.lsp.config('cmake', {
        capabilities = capabilities,
        cmd = { 'cmake-language-server' },
        filetypes = { 'cmake' },
        root_markers = { 'CMakeLists.txt', '.git' },
      })

      vim.lsp.config('lua_ls', {
        capabilities = capabilities,
        settings = {
          Lua = {
            diagnostics = { globals = { 'vim' } },
          },
        },
      })

      vim.lsp.enable('clangd')
      vim.lsp.enable('cmake')
      vim.lsp.enable('lua_ls')
    end,
  },

  -- Autocompletion
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
      'rafamadriz/friendly-snippets',
    },
    config = function()
      local cmp = require('cmp')
      local luasnip = require('luasnip')
      require('luasnip.loaders.from_vscode').lazy_load()

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-k>'] = cmp.mapping.select_prev_item(),
          ['<C-j>'] = cmp.mapping.select_next_item(),
          ['<C-d>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),
        }),
        sources = {
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'buffer' },
          { name = 'path' },
        },
      })

      cmp.setup.cmdline(':', {
        sources = cmp.config.sources({ { name = 'cmdline' } }),
      })
    end,
  },

  -- Git integration
  {
    'lewis6991/gitsigns.nvim',
    config = function()
      require('gitsigns').setup({
        signs = {
          add = { text = '+' },
          change = { text = '~' },
          delete = { text = '_' },
          topdelete = { text = '‾' },
          changedelete = { text = '~' },
        },
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end
          map('n', ']c', function() gs.next_hunk() end)
          map('n', '[c', function() gs.prev_hunk() end)
        end,
      })
    end,
  },

  -- Autopairs
  {
    'windwp/nvim-autopairs',
    config = function()
      require('nvim-autopairs').setup()
    end,
  },

  -- Comment plugin
  {
    'numToStr/Comment.nvim',
    config = function()
      require('Comment').setup()
    end,
  },

  -- Indent guides
  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    config = function()
      require('ibl').setup()
    end,
  },

  -- Which-key for key bindings
  {
    'folke/which-key.nvim',
    config = function()
      require('which-key').setup({
        preset = 'helix',
        delay = 200,
      })
    end,
  },

  -- Multi-cursor support
  {
    'mg979/vim-visual-multi',
  },

  -- Smooth scrolling
  {
    'karb94/neoscroll.nvim',
    config = function()
      require('neoscroll').setup()
    end,
  },

  -- CMake integration
  {
    'Civitasv/cmake-tools.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('cmake-tools').setup({
        cmake_command = 'cmake',
        cmake_build_directory = 'build',
        cmake_generate_options = { '-DCMAKE_EXPORT_COMPILE_COMMANDS=1', '-DCMAKE_BUILD_TYPE=Debug' },
        cmake_build_options = {},
        cmake_console_size = 10,
        cmake_show_console = 'always',
      })
    end,
  },

  -- Better C++ syntax
  {
    'octol/vim-cpp-enhanced-highlight',
  },

  -- Debugging support
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      'nvim-neotest/nvim-nio',
      'rcarriga/nvim-dap-ui',
      'theHamsta/nvim-dap-virtual-text',
    },
    config = function()
      local dap = require('dap')
      local dapui = require('dapui')

      dapui.setup({
        layouts = {
          {
            elements = { 'scopes', 'breakpoints', 'stacks', 'watches' },
            size = 40,
            position = 'left',
          },
          {
            elements = { 'repl', 'console' },
            size = 10,
            position = 'bottom',
          },
        },
      })
      require('nvim-dap-virtual-text').setup()

      dap.adapters.cppdbg = {
        id = 'cppdbg',
        type = 'executable',
        command = 'lldb-vscode',
      }

      dap.configurations.cpp = {
        {
          name = 'Launch',
          type = 'cppdbg',
          request = 'launch',
          program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/build/', 'file')
          end,
          cwd = '${workspaceFolder}',
          stopAtEntry = false,
          setupCommands = {
            {
              description = 'enable pretty printing',
              text = '-enable-pretty-printing',
              ignoreFailures = true,
            },
          },
        },
      }
      dap.configurations.c = dap.configurations.cpp

      dap.listeners.after.event_initialized['dapui_config'] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated['dapui_config'] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited['dapui_config'] = function()
        dapui.close()
      end
    end,
  },

  -- Faster movement with Hop
  {
    'phaazon/hop.nvim',
    branch = 'v2',
    config = function()
      require('hop').setup()
    end,
  },

  -- Treesitter-based code selection
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    dependencies = 'nvim-treesitter/nvim-treesitter',
    config = function()
      require('nvim-treesitter.configs').setup({
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ['af'] = '@function.outer',
              ['if'] = '@function.inner',
              ['ac'] = '@class.outer',
              ['ic'] = '@class.inner',
            },
          },
          move = {
            enable = true,
            set_jumps = true,
            goto_next_start = { [']f'] = '@function.outer', [']c'] = '@class.outer' },
            goto_prev_start = { ['[f'] = '@function.outer', ['[c'] = '@class.outer' },
          },
        },
      })
    end,
  },

  -- Persistent session management
  {
    'folke/persistence.nvim',
    event = 'BufReadPre',
    config = function()
      require('persistence').setup({
        dir = vim.fn.expand(vim.fn.stdpath('data') .. '/sessions/'),
        options = { 'buffers', 'curdir', 'tabpages', 'winsize' },
      })
    end,
  },

  -- Search and replace UI
  {
    'MagicDuck/grug-far.nvim',
    config = function()
      require('grug-far').setup()
    end,
  },
})


