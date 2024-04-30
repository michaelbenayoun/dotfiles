local cmd = vim.cmd
local fn = vim.fn
local g = vim.g
local opt = vim.opt

-- General edition configuration
opt.softtabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.backspace="indent,eol,start"
opt.pastetoggle="<F12>"

-- Plugins mapping
g.mapleader = ","

-- fzf
vim.keymap.set('n', '<C-p>', ':GFiles<CR>')
vim.keymap.set('n', '<leader>p', ':Files<CR>')
vim.keymap.set('n', '<C-g>', ':Rg<CR>')
vim.keymap.set('n', '<leader>l', ':Buffers<CR>')

g.fzf_colors = { 
   -- fg = {'fg', 'Normal'},
   -- bg = {'bg', 'Normal'},
   -- hl = {'fg', 'Comment'},
   -- fg+ = {'fg', 'CursorLine', 'CursorColumn', 'Normal'},
   -- bg+ = {'bg', 'CursorLine', 'CursorColumn'},
   -- hl+ = {'fg', 'Statement'},
   info = {'fg', 'PreProc'},
   border =  {'fg', 'Class'},
   prompt = {'fg', 'Conditional'},
   pointer = {'fg', 'Exception'},
   marker = {'fg', 'Keyword'},
   spinner = {'fg', 'Label'},
   header = {'fg', 'Comment'}
}
g.fzf_colors["fg+"] = {'fg', 'Exception', 'CursorLine', 'CursorColumn', 'Normal'}
g.fzf_colors["bg+"] = {'fg', 'CursorLine', 'CursorColumn'}
g.fzf_colors["hl+"] = {'fg', 'Statement'}


---WORKAROUND
-- vim.api.nvim_create_autocmd({'BufEnter','BufAdd','BufNew','BufNewFile','BufWinEnter'}, {
--   group = vim.api.nvim_create_augroup('TS_FOLD_WORKAROUND', {}),
--   callback = function()
--     vim.opt.foldmethod     = 'expr'
--     vim.opt.foldexpr       = 'nvim_treesitter#foldexpr()'
--   end
-- })
---ENDWORKAROUND

-- Packer plugin manager.
opt.runtimepath = vim.fn.stdpath('data') .. '/site/pack/*/start/*,' .. vim.o.runtimepath
local ensure_packer = function()
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    cmd [[packadd packer.nvim]]
    return true
  end
  return false
end


local packer_bootstrap = ensure_packer()
local use = require('packer').use

require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'
  use {
    'nvim-treesitter/nvim-treesitter',
    run = function()
      local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
      ts_update()
    end,
  }
  use 'neovim/nvim-lspconfig' -- Collection of configurations for built-in LSP client
  use 'hrsh7th/nvim-cmp' -- Autocompletion plugin
  use 'hrsh7th/cmp-nvim-lsp' -- LSP source for nvim-cmp
  use 'saadparwaiz1/cmp_luasnip' -- Snippets source for nvim-cmp
  use 'L3MON4D3/LuaSnip' -- Snippets plugin
  use 'junegunn/fzf'
  use 'junegunn/fzf.vim'
  use { 'dracula/vim', as = 'dracula' }
  use { "catppuccin/nvim", as = "catppuccin" }
  use 'romainl/vim-cool'
  use 'tpope/vim-obsession'
  use {
    "stevearc/aerial.nvim",
    config = function()
      require("aerial").setup()
    end,
  }


  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if packer_bootstrap then
    require('packer').sync()
  end
end)

-- Setup language servers.
local lspconfig = require('lspconfig')
lspconfig.pyright.setup {}
lspconfig.tsserver.setup {}
lspconfig.rust_analyzer.setup {
  -- Server-specific settings. See `:help lspconfig-setup`
  settings = {
    ['rust-analyzer'] = {},
  },
}

-- Global mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local opts = { buffer = ev.buf }
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
    vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
    vim.keymap.set('n', '<space>wl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)
    vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', '<space>f', function()
      vim.lsp.buf.format { async = true }
    end, opts)
  end,
})

-- luasnip setup
local luasnip = require 'luasnip'

-- nvim-cmp setup
local cmp = require 'cmp'
cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-u>'] = cmp.mapping.scroll_docs(-4), -- Up
    ['<C-d>'] = cmp.mapping.scroll_docs(4), -- Down
    -- C-b (back) C-f (forward) for snippet placeholder navigation.
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
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
  },
}

require("aerial").setup({
  -- optionally use on_attach to set keymaps when aerial has attached to a buffer
  on_attach = function(bufnr)
    -- Jump forwards/backwards with '{' and '}'
    vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
    vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr })
  end,
  default_direction = "prefer_left",
  filter_kind = {
    "Class",
    "Constructor",
    "Enum",
    "Function",
    "Interface",
    -- "Module",
    "Method",
    "Struct",
  },
})
-- You probably also want to set a keymap to toggle aerial
vim.keymap.set("n", "<leader>a", "<cmd>AerialToggle!<CR>")

-- Colorscheme

-- Dracula
-- g.dracula_colorterm = 0
-- g.dracula_italic = 0
-- cmd[[silent! colorscheme dracula]] 

-- Catppuccin
require("catppuccin").setup({
    -- flavour = "auto", -- latte, frappe, macchiato, mocha
    flavour = "macchiato", -- latte, frappe, macchiato, mocha
    background = { -- :h background
        light = "latte",
        dark = "mocha",
    },
    transparent_background = true, -- disables setting the background color.
    show_end_of_buffer = false, -- shows the '~' characters after the end of buffers
    term_colors = false, -- sets terminal colors (e.g. `g:terminal_color_0`)
    dim_inactive = {
        enabled = false, -- dims the background color of inactive window
        shade = "dark",
        percentage = 0.15, -- percentage of the shade to apply to the inactive window
    },
    no_italic = false, -- Force no italic
    no_bold = false, -- Force no bold
    no_underline = false, -- Force no underline
    styles = { -- Handles the styles of general hi groups (see `:h highlight-args`):
        comments = { "italic" }, -- Change the style of comments
        conditionals = { "italic" },
        loops = {},
        functions = {},
        keywords = {},
        strings = {},
        variables = {},
        numbers = {},
        booleans = {},
        properties = {},
        types = {},
        operators = {},
        -- miscs = {}, -- Uncomment to turn off hard-coded styles
    },
    color_overrides = {},
    custom_highlights = function(colors)
        return {
            Comment = { fg = colors.flamingo },
            -- TabLineSel = { bg = colors.pink },
            -- CmpBorder = { fg = colors.surface2 },
            -- Pmenu = { bg = colors.none },
        }
    end,
    -- custom_highlights = {},
    default_integrations = true,
    integrations = {
        cmp = true,
        gitsigns = false,
        nvimtree = false,
        treesitter = true,
        notify = false,
        mini = {
            enabled = false,
            indentscope_color = "",
        },
        native_lsp = {
          enabled = true,
          virtual_text = {
              errors = { "italic" },
              hints = { "italic" },
              warnings = { "italic" },
              information = { "italic" },
          },
          underlines = {
              errors = { "underline" },
              hints = { "underline" },
              warnings = { "underline" },
              information = { "underline" },
          },
          inlay_hints = {
              background = true,
          },
        },
        -- For more plugins integrations please scroll down (https://github.com/catppuccin/nvim#integrations)
    },
})

-- setup must be called before loading
cmd[[colorscheme catppuccin]]

opt.laststatus = 0
opt.guicursor = "i:block"
-- opt.fillchars:append("vert:|")
cmd [[hi VertSplit cterm=NONE guibg=NONE]]

-- " Color management
-- "set background=dark
-- "set t_Co=256
-- let &t_8f="\<Esc>[38;2;%lu;%lu;%lum"
-- let &t_8b="\<Esc>[48;2;%lu;%lu;%lum"

-- Treesitter configuration
require'nvim-treesitter.configs'.setup {
  ensure_installed = {
    "bash",
    "c",
    "json",
    "lua",
    "markdown",
    "python",
    "regex",
    "rust",
    "vim",
    "vimdoc",
  },
  highlight = {
    enable = true,
    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "gnn", -- set to `false` to disable one of the mappings
      node_incremental = "grn",
      scope_incremental = "grc",
      node_decremental = "grm",
    },
  },
  indent = {
    enable = true,
  },
}
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
-- opt.foldtext = "v:lua.vim.treesitter.foldtext()"
opt.foldenable = false
