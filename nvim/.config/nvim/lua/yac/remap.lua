-- useful vars
local opts = { noremap = true, silent = true }

-- normal mode remaps
vim.g.mapleader = " "


-- Modes
--   normal_mode = "n",
--   insert_mode = "i",
--   visual_mode = "v",
--   visual_block_mode = "x",
--   term_mode = "t",
--   command_mode = "c"


-- space+p+v => vim Explorer
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- space+enter => source init.lua
vim.keymap.set("n", "<leader><CR>", ":so ~/.config/nvim/init.lua<CR>", opts)

-- not working i need to get better at quick lists
vim.keymap.set("n", "<C-o>", ":copen<CR>", opts)

-- middle of the window, then half a page down
vim.keymap.set("n", "<C-d>", "M<C-d>", opts)

-- half a page up, then center
vim.keymap.set("n", "<C-u>", "<C-u>zz", opts)

-- five lines, like the VS Code vim bindings
vim.keymap.set("n", "J", "5j", opts)
vim.keymap.set("n", "K", "5k", opts)

-- join lines; noremap so this stays the builtin J
vim.keymap.set("n", "<leader>j", "J", opts)

-- command palette
vim.keymap.set("n", "<leader>p", function()
  require("telescope.builtin").commands()
end, opts)

local function jump_diagnostic(direction)
  local diagnostics = vim.diagnostic.get(nil)
  if #diagnostics == 0 then
    return
  end

  local name_of = function(bufnr)
    return vim.api.nvim_buf_get_name(bufnr)
  end

  table.sort(diagnostics, function(a, b)
    local an = name_of(a.bufnr)
    local bn = name_of(b.bufnr)
    if an ~= bn then
      return an < bn
    end
    if a.lnum ~= b.lnum then
      return a.lnum < b.lnum
    end
    return a.col < b.col
  end)

  local bufnr = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row, col = cursor[1] - 1, cursor[2]
  local current = name_of(bufnr)
  local index

  if direction > 0 then
    for i, diagnostic in ipairs(diagnostics) do
      local name = name_of(diagnostic.bufnr)
      local after = name > current
        or (name == current and (diagnostic.lnum > row or (diagnostic.lnum == row and diagnostic.col > col)))
      if after then
        index = i
        break
      end
    end
    index = index or 1
  else
    for i = #diagnostics, 1, -1 do
      local diagnostic = diagnostics[i]
      local name = name_of(diagnostic.bufnr)
      local before = name < current
        or (name == current and (diagnostic.lnum < row or (diagnostic.lnum == row and diagnostic.col < col)))
      if before then
        index = i
        break
      end
    end
    index = index or #diagnostics
  end

  local target = diagnostics[index]
  vim.api.nvim_set_current_buf(target.bufnr)
  vim.api.nvim_win_set_cursor(0, { target.lnum + 1, target.col })
  vim.diagnostic.open_float()
end

vim.keymap.set("n", "n", function()
  jump_diagnostic(1)
end, opts)
vim.keymap.set("n", "N", function()
  jump_diagnostic(-1)
end, opts)

--space+s rename occurences
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

-- space+x make file executable
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

--map control +c to Escape. that way to have completly same behaviour
vim.keymap.set("n", "<C-c>", "<Esc>")

--dont use Q
vim.keymap.set("n", "<Q>", "<nop>")

-- open new tmux session with fzf
vim.keymap.set("n", "<C-f>", ":silent !tmux neww ~/.config/tmux-sessionizer <CR>")

-- space + f => format file if lsp installed
--vim.keymap.set("n", "<leader>f", function()
--    vim.lsp.buf.format()
--end)

vim.keymap.set("n", "<C-*>", ":e#<CR>", opts)

vim.keymap.set("n", "<C-j>", ":cnext<CR>", opts)
vim.keymap.set("n", "<C-k>", ":cprev<CR>", opts)

vim.keymap.set("n", "<leader>n", ":bn<CR>", opts)
vim.keymap.set("n", "<leader>b", ":bp<CR>", opts)
-- visual mode remaps

--ability to paste without losing current vim reg content
vim.keymap.set("x", "<leader>p", "\"_dP", opts)

-- ability to copy to system clipboard vim code
vim.keymap.set("v", "<leader>y", '"+y', opts)

--ability to move in visual mode selected line down
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", opts)

--ability to move in visual mode selected line up
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", opts)

-- remap toggle folding to space space

vim.keymap.set("n", "<leader><leader>", ":exe 'normal! za'<CR>", opts)

-- Bottom terminal, same session each time. Ctrl+` never reaches nvim from a
-- terminal emulator, so Ctrl+\ is the key that actually arrives.
local terminal = { buf = nil }

local function terminal_running(buf)
  if not buf or not vim.api.nvim_buf_is_valid(buf) or vim.bo[buf].buftype ~= "terminal" then
    return false
  end

  local job_id = vim.b[buf].terminal_job_id
  if not job_id then
    return false
  end

  return vim.fn.jobwait({ job_id }, 0)[1] == -1
end

local function terminal_window()
  if not terminal_running(terminal.buf) then
    return nil
  end

  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win) == terminal.buf then
      return win
    end
  end
end

local function toggle_terminal()
  local win = terminal_window()
  if win then
    vim.api.nvim_win_hide(win)
    return
  end

  vim.cmd("botright 12split")
  if terminal_running(terminal.buf) then
    vim.api.nvim_win_set_buf(0, terminal.buf)
  else
    vim.cmd("terminal")
    terminal.buf = vim.api.nvim_get_current_buf()
    vim.bo.buflisted = false
  end

  vim.wo.number = false
  vim.wo.relativenumber = false
  vim.wo.signcolumn = "no"
  vim.cmd("startinsert")
end

vim.keymap.set({ "n", "i", "t" }, "<C-\\>", toggle_terminal, { noremap = true, silent = true, nowait = true })
vim.keymap.set({ "n", "i", "t" }, "<C-`>", toggle_terminal, { noremap = true, silent = true, nowait = true })

-- :Lsp prints the language servers attached to this buffer
vim.api.nvim_create_user_command("Lsp", function()
  local names = vim.tbl_map(function(client)
    return client.name
  end, vim.lsp.get_clients({ bufnr = 0 }))

  if #names == 0 then
    vim.notify("No LSP attached", vim.log.levels.WARN)
    return
  end

  vim.notify(table.concat(names, ", "))
end, { desc = "Show LSP clients attached to this buffer" })
