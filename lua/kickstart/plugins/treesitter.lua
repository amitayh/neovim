-- Highlight, edit, and navigate code with Treesitter.
--
-- NOTE: We use the `main` branch of nvim-treesitter. The `master` branch is
-- frozen and does not support Neovim 0.12+. The `main` branch dropped the old
-- module system, so highlighting/indentation/incremental-selection are wired up
-- manually below. See `:help nvim-treesitter`.

-- Languages to install parsers for.
local ensure_installed = {
  'bash',
  'c',
  'diff',
  'html',
  'lua',
  'luadoc',
  'markdown',
  'markdown_inline',
  'vim',
  'vimdoc',
  'rust',
  'scala',
  'javascript',
  'typescript',
}

-- [[ Incremental selection ]]
-- <C-space> selects the node under the cursor, then grows to the parent node on
-- each press; <BS> shrinks back one step.
local node_stack = {} -- per-buffer stack of selected nodes

local function same_range(a, b)
  local a1, a2, a3, a4 = a:range()
  local b1, b2, b3, b4 = b:range()
  return a1 == b1 and a2 == b2 and a3 == b3 and a4 == b4
end

local function select_node(node)
  local buf = vim.api.nvim_get_current_buf()
  -- Drop any existing visual selection so we can set a fresh one.
  if vim.api.nvim_get_mode().mode:match '[vV\22]' then
    vim.cmd 'normal! \27'
  end
  local srow, scol, erow, ecol = node:range()
  vim.fn.setpos('.', { buf, srow + 1, scol + 1, 0 })
  vim.cmd 'normal! v'
  if ecol == 0 then
    -- Range ends at column 0 of erow, i.e. through the end of the line above.
    vim.fn.setpos('.', { buf, erow, vim.fn.col { erow, '$' }, 0 })
  else
    vim.fn.setpos('.', { buf, erow + 1, ecol, 0 })
  end
end

local function init_selection()
  local node = vim.treesitter.get_node()
  if not node then
    return
  end
  node_stack[vim.api.nvim_get_current_buf()] = { node }
  select_node(node)
end

local function node_incremental()
  local buf = vim.api.nvim_get_current_buf()
  local stack = node_stack[buf]
  if not stack or #stack == 0 then
    return init_selection()
  end
  local node = stack[#stack]
  local parent = node:parent()
  while parent and same_range(parent, node) do
    parent = parent:parent()
  end
  if parent then
    stack[#stack + 1] = parent
    node = parent
  end
  select_node(node)
end

local function node_decremental()
  local buf = vim.api.nvim_get_current_buf()
  local stack = node_stack[buf]
  if not stack or #stack == 0 then
    return
  end
  if #stack > 1 then
    stack[#stack] = nil
  end
  select_node(stack[#stack])
end

return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    build = ':TSUpdate',
    config = function()
      -- Install/update the parsers above (no-op for already up-to-date ones).
      require('nvim-treesitter').install(ensure_installed)

      -- Highlighting is provided natively by Neovim via `vim.treesitter.start()`;
      -- indentation is provided by nvim-treesitter's `indentexpr`. Enable both
      -- per-buffer whenever a parser is available for the filetype.
      vim.api.nvim_create_autocmd('FileType', {
        callback = function()
          if pcall(vim.treesitter.start) then
            vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })

      vim.keymap.set('n', '<C-space>', init_selection, { desc = 'Treesitter: init incremental selection' })
      vim.keymap.set('x', '<C-space>', node_incremental, { desc = 'Treesitter: increment selection' })
      vim.keymap.set('x', '<BS>', node_decremental, { desc = 'Treesitter: decrement selection' })
    end,
  },
}
