-- lazy.nvim
require("config.lazy")

  local cmd = vim.cmd
  local fn = vim.fn
  local g = vim.g
  
  -- fzf
  vim.keymap.set('n', '<C-p>', ':GFiles<CR>')
  vim.keymap.set('n', '<leader>p', ':Files<CR>')
  vim.keymap.set('n', '<C-g>', ':Rg<CR>')
  vim.keymap.set('n', '<leader>l', ':Buffers<CR>')
  
  g.fzf_colors = { 
     fg = {'fg', 'Normal'},
     bg = {'bg', 'Normal'},
     hl = {'fg', 'Comment'},
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
  
  

-- Setup language servers.
vim.lsp.config.pyright = {
  settings = {
    python = {
      analysis = {
        typeCheckingMode = "basic", -- or "strict" for more aggressive checking
        autoImportCompletions = true,
      }
    }
  }
}

vim.lsp.config.ruff = {} -- Fast Python linting/formatting

vim.lsp.config.vtsls = {} -- Modern TypeScript server (replaces ts_ls)

vim.lsp.config.rust_analyzer = {
  settings = {
    ['rust-analyzer'] = {
      cargo = { allFeatures = true },
      check = {
        command = "clippy",
      },
      imports = {
        granularity = {
          group = "module",
        },
        prefix = "self",
      },
    },
  },
}

vim.lsp.config.clangd = {
  cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--header-insertion=iwyu",
  },
}

vim.lsp.config.mlir_lsp_server = {}
vim.lsp.config.tblgen_lsp_server = {}

-- Enable all servers
local servers = {
  'pyright', 'ruff', 'vtsls', 'rust_analyzer', 
  'clangd', 'mlir_lsp_server', 'tblgen_lsp_server'
}

for _, server in ipairs(servers) do
  vim.lsp.enable(server)
end


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

-- GitHub Copilot mappings.
vim.g.copilot_no_tab_map = true
vim.api.nvim_set_keymap('i', '<C-l>', 'copilot#Accept("")', { expr = true, silent = true })
-- Next suggestion
vim.keymap.set('i', '<M-]>', '<Cmd>call copilot#Next()<CR>', { silent = true })
-- Previous suggestion
vim.keymap.set('i', '<M-[>', '<Cmd>call copilot#Previous()<CR>', { silent = true })
-- Dismiss current suggestion
vim.keymap.set('i', '<M-x>', '<Cmd>call copilot#Dismiss()<CR>', { silent = true })
-- Toggle Copilot on/off
vim.keymap.set('i', '<M-c>', '<Cmd>Copilot toggle<CR>', { silent = true })
-- Show Copilot suggestions panel
vim.keymap.set('i', '<M-p>', '<Cmd>Copilot panel<CR>', { silent = true })

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

-- Colorschemes
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

-- opt.fillchars:append("vert:|")
cmd [[hi VertSplit cterm=NONE guibg=NONE]]

-- " Color management
-- "set background=dark
-- "set t_Co=256
-- let &t_8f="\<Esc>[38;2;%lu;%lu;%lum"
-- let &t_8b="\<Esc>[48;2;%lu;%lu;%lum"


-- Support for MDX files with nvim-treesitter
vim.filetype.add({
  extension = {
    mdx = "markdown"
  }
})

-- Leader+d to delete/cut to system clipboard
vim.keymap.set({'n', 'v'}, '<leader>d', '"+d')
vim.keymap.set('n', '<leader>dd', '"+dd')

-- Leader+y to yank/copy to system clipboard
vim.keymap.set({'n', 'v'}, '<leader>y', '"+y')
vim.keymap.set('n', '<leader>yy', '"+yy')

-- Leader+p to paste from system clipboard
vim.keymap.set({'n', 'v'}, '<leader>v', '"+p')
vim.keymap.set({'n', 'v'}, '<leader>v', '"+P')  -- paste before cursor

-- Optional: Leader+p in insert mode
vim.keymap.set('i', '<leader>p', '<C-r>+')
