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
  
-- =============================================================================
-- LSP Configuration
-- =============================================================================

-- Add capabilities from cmp_nvim_lsp for better completion support
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- -----------------------------------------------------------------------------
-- Python: Pyright (global) + Ruff (project-local via uv)
-- -----------------------------------------------------------------------------
vim.lsp.config.pyright = {
  cmd = { "pyright-langserver", "--stdio" },
  filetypes = { "python" },
  capabilities = capabilities,
  before_init = function(_, config)
    local venv = vim.fn.getcwd() .. "/.venv"
    if vim.fn.isdirectory(venv) == 1 then
      config.settings.python.pythonPath = venv .. "/bin/python"
    end
  end,
  settings = {
    pyright = {
      disableOrganizeImports = true,
    },
    python = {
      analysis = {
        typeCheckingMode = "basic",
        autoImportCompletions = true,
        diagnosticSeverityOverrides = {
          reportUnusedImport = "none",
          reportUnusedVariable = "none",
        },
      },
    },
  },
}

vim.lsp.config.ruff = {
  cmd = { "ruff", "server" },
  filetypes = { "python" },
  capabilities = capabilities,
  before_init = function(_, config)
    local venv = vim.fn.getcwd() .. "/.venv"
    if vim.fn.isdirectory(venv) == 1 then
      local ruff_path = venv .. "/bin/ruff"
      if vim.fn.executable(ruff_path) == 1 then
        config.cmd = { ruff_path, "server" }
      else
        vim.notify("No ruff in .venv, using global", vim.log.levels.WARN)
      end
    end
  end,
  init_options = {
    settings = {
      lineLength = 88,
      lint = {
        select = { "E", "F", "UP", "B", "SIM", "I" },
      },
    },
  },
}

-- -----------------------------------------------------------------------------
-- Rust: rust-analyzer with clippy
-- -----------------------------------------------------------------------------
vim.lsp.config.rust_analyzer = {
  cmd = { "rust-analyzer" },
  filetypes = { "rust" },
  root_markers = { "Cargo.toml", "rust-project.json" },
  capabilities = capabilities,
  settings = {
    ["rust-analyzer"] = {
      cargo = {
        allFeatures = true,
        loadOutDirsFromCheck = true,
      },
      check = {
        command = "clippy",
        extraArgs = {
          "--",
          "-W", "clippy::pedantic",
          "-W", "clippy::nursery",
          "-A", "clippy::module_name_repetitions",
          "-A", "clippy::too_many_lines",
        },
      },
      procMacro = {
        enable = true,
      },
      imports = {
        granularity = { group = "module" },
        prefix = "self",
      },
      completion = {
        postfix = { enable = true },
      },
      inlayHints = {
        bindingModeHints = { enable = true },
        closureCaptureHints = { enable = true },
        closureReturnTypeHints = { enable = "with_block" },
        lifetimeElisionHints = { enable = "skip_trivial" },
      },
    },
  },
}

-- -----------------------------------------------------------------------------
-- C/C++: clangd
-- -----------------------------------------------------------------------------
vim.lsp.config.clangd = {
  capabilities = capabilities,
  filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
  cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--header-insertion=iwyu",
    "--completion-style=detailed",
    "--function-arg-placeholders",
  },
}

-- -----------------------------------------------------------------------------
-- MLIR / TableGen
-- -----------------------------------------------------------------------------
vim.lsp.config.mlir_lsp_server = { capabilities = capabilities }
vim.lsp.config.tblgen_lsp_server = { capabilities = capabilities }

-- -----------------------------------------------------------------------------
-- Enable servers
-- -----------------------------------------------------------------------------
local servers = {
  "pyright", "ruff", "rust_analyzer",
  "clangd", "mlir_lsp_server", "tblgen_lsp_server",
}
for _, server in ipairs(servers) do
  vim.lsp.enable(server)
end

-- -----------------------------------------------------------------------------
-- Inlay hints (enabled by default)
-- -----------------------------------------------------------------------------
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspInlayHints", {}),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    -- Only enable inlay hints for buffers with valid file paths
    local bufname = vim.api.nvim_buf_get_name(args.buf)
    if client and client.supports_method("textDocument/inlayHint") and bufname ~= "" then
      vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
    end
  end,
})

-- -----------------------------------------------------------------------------
-- Diagnostics keymaps (global)
-- -----------------------------------------------------------------------------
vim.keymap.set("n", "<space>e", vim.diagnostic.open_float, { desc = "Show diagnostic float" })
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
vim.keymap.set("n", "<space>q", vim.diagnostic.setloclist, { desc = "Diagnostics to loclist" })

-- -----------------------------------------------------------------------------
-- LSP keymaps (buffer-local on attach)
-- -----------------------------------------------------------------------------
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, desc = desc })
    end

    -- Navigation
    map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
    map("n", "gd", vim.lsp.buf.definition, "Go to definition")
    map("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
    map("n", "gr", vim.lsp.buf.references, "Find references")
    map("n", "<space>D", vim.lsp.buf.type_definition, "Type definition")

    -- Documentation
    map("n", "K", vim.lsp.buf.hover, "Hover documentation")
    map("n", "<C-k>", vim.lsp.buf.signature_help, "Signature help")

    -- Refactoring
    map("n", "<space>rn", vim.lsp.buf.rename, "Rename symbol")
    map({ "n", "v" }, "<space>ca", vim.lsp.buf.code_action, "Code action")
    map("n", "<space>f", function()
      vim.lsp.buf.format({ async = true })
    end, "Format buffer")

    -- Workspace
    map("n", "<space>wa", vim.lsp.buf.add_workspace_folder, "Add workspace folder")
    map("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, "Remove workspace folder")
    map("n", "<space>wl", function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, "List workspace folders")

    -- Toggle inlay hints
    map("n", "<space>th", function()
      vim.lsp.inlay_hint.enable(
        not vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf }),
        { bufnr = ev.buf }
      )
    end, "Toggle inlay hints")
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
-- Global Copilot toggle function
local function toggle_copilot_global()
  if vim.g.copilot_enabled == false then
    vim.cmd('Copilot enable')
    vim.g.copilot_enabled = true
    print('Copilot enabled globally')
  else
    vim.cmd('Copilot disable')
    vim.g.copilot_enabled = false
    print('Copilot disabled globally')
  end
end

-- Toggle Copilot on/off (global) - normal mode
vim.keymap.set('n', '<leader>cg', toggle_copilot_global, { silent = false, desc = 'Toggle Copilot globally' })
-- Show Copilot suggestions panel
vim.keymap.set('i', '<M-p>', '<Cmd>Copilot panel<CR>', { silent = true })

-- Buffer-specific Copilot toggle function
local function toggle_copilot_buffer()
  local buf = vim.api.nvim_get_current_buf()
  if vim.b[buf].copilot_enabled == false then
    vim.cmd('Copilot enable')
    vim.b[buf].copilot_enabled = true
    print('Copilot enabled for this buffer')
  else
    vim.cmd('Copilot disable')
    vim.b[buf].copilot_enabled = false
    print('Copilot disabled for this buffer')
    
  end
end

-- Toggle Copilot for current buffer - normal mode
vim.keymap.set('n', '<leader>ct', toggle_copilot_buffer, { silent = false, desc = 'Toggle Copilot for buffer' })

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
