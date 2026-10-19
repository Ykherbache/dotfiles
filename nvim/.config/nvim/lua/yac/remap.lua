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


-- extra replaces the shared silent opts. Pass {} when the map must not be silent.
local function map(mode, lhs, rhs, desc, extra)
  vim.keymap.set(mode, lhs, rhs, vim.tbl_extend("force", extra or opts, { desc = desc }))
end

-- space+p+v => vim Explorer
map("n", "<leader>pv", vim.cmd.Ex, "File explorer", {})

-- In netrw: d = new directory, f = new file (stock netrw uses %)
vim.api.nvim_create_autocmd("FileType", {
  pattern = "netrw",
  group = vim.api.nvim_create_augroup("NetrwMaps", { clear = true }),
  callback = function(event)
    vim.keymap.set("n", "f", "%", {
      buffer = event.buf,
      remap = true,
      desc = "Create file",
    })
  end,
})

-- space+enter => source init.lua
map("n", "<leader><CR>", ":so ~/.config/nvim/init.lua<CR>", "Reload config")

-- not working i need to get better at quick lists
map("n", "<C-o>", ":copen<CR>", "Open quickfix")

-- middle of the window, then half a page down
map("n", "<C-d>", "M<C-d>", "Half page down")

-- half a page up, then center
map("n", "<C-u>", "<C-u>zz", "Half page up, centered")

-- five lines, like the VS Code vim bindings
map("n", "J", "5j", "Down 5 lines")
map("n", "K", "5k", "Up 5 lines")

-- join lines; noremap so this stays the builtin J
map("n", "<leader>j", "J", "Join lines")

-- command palette
map("n", "<leader>p", function()
  require("telescope.builtin").commands()
end, "Command palette")

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

map("n", "n", function()
  jump_diagnostic(1)
end, "Next diagnostic")
map("n", "N", function()
  jump_diagnostic(-1)
end, "Previous diagnostic")

--space+s rename occurences
map("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], "Substitute word", {})

-- space+x make file executable
map("n", "<leader>x", "<cmd>!chmod +x %<CR>", "Make file executable", { silent = true })

--map control +c to Escape. that way to have completly same behaviour
map("n", "<C-c>", "<Esc>", "Escape", {})

--dont use Q
map("n", "<Q>", "<nop>", "Disabled", {})

-- open new tmux session with fzf
map("n", "<C-f>", ":silent !tmux neww ~/.config/tmux-sessionizer <CR>", "New tmux session", {})

map("n", "<C-*>", ":e#<CR>", "Alternate file")

map("n", "<C-j>", ":cnext<CR>", "Next quickfix")
map("n", "<C-k>", ":cprev<CR>", "Previous quickfix")

-- Moving in the list from gd keeps the file you came from on that line.
-- Enter jumps there and closes the list.
local function list_info(winid)
  if not vim.api.nvim_win_is_valid(winid) then
    return nil
  end
  local info = vim.fn.getwininfo(winid)[1]
  if info == nil or info.quickfix ~= 1 then
    return nil
  end
  return info
end

local function list_is_loclist(winid)
  local info = list_info(winid)
  return info ~= nil and info.loclist == 1
end

local function list_items(winid)
  if list_is_loclist(winid) then
    return vim.fn.getloclist(winid)
  end
  return vim.fn.getqflist()
end

local function file_window(winid, list_win)
  if winid == 0 or winid == list_win or not vim.api.nvim_win_is_valid(winid) then
    return false
  end
  local info = vim.fn.getwininfo(winid)[1]
  if info == nil or info.quickfix == 1 then
    return false
  end
  return vim.bo[vim.api.nvim_win_get_buf(winid)].buftype == ""
end

local function origin_window(list_win)
  local prev = vim.fn.win_getid(vim.fn.winnr("#"))
  if file_window(prev, list_win) then
    return prev
  end
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if file_window(win, list_win) then
      return win
    end
  end
end

local function list_entry(winid)
  local items = list_items(winid)
  local item = items[vim.api.nvim_win_get_cursor(winid)[1]]
  if item == nil or item.valid == 0 then
    return nil
  end
  return item
end

local function entry_buffer(item)
  local buf = item.bufnr
  if buf ~= nil and buf ~= 0 and vim.api.nvim_buf_is_valid(buf) then
    return buf
  end
  if item.filename == nil or item.filename == "" then
    return nil
  end
  local added = vim.fn.bufadd(item.filename)
  if added == 0 or not vim.api.nvim_buf_is_valid(added) then
    return nil
  end
  return added
end

local function close_list(winid)
  if list_is_loclist(winid) then
    vim.cmd.lclose()
  else
    vim.cmd.cclose()
  end
end

local showing_list_entry = false

local function show_list_entry(close_after)
  if showing_list_entry then
    return false
  end

  local list_win = vim.api.nvim_get_current_win()
  if list_info(list_win) == nil then
    return false
  end
  local item = list_entry(list_win)
  local origin = origin_window(list_win)
  if item == nil or origin == nil then
    return false
  end
  local buf = entry_buffer(item)
  if buf == nil then
    return false
  end

  showing_list_entry = true
  local shown = pcall(function()
    vim.fn.bufload(buf)
    vim.bo[buf].buflisted = true
    vim.api.nvim_win_set_buf(origin, buf)
    local last = vim.api.nvim_buf_line_count(buf)
    local lnum = item.lnum or 1
    if lnum < 1 then
      lnum = 1
    end
    if last > 0 and lnum > last then
      lnum = last
    end
    local text = vim.api.nvim_buf_get_lines(buf, lnum - 1, lnum, false)[1] or ""
    local col = math.max((item.col or 1) - 1, 0)
    if col > #text then
      col = #text
    end
    vim.api.nvim_win_set_cursor(origin, { lnum, col })
    vim.api.nvim_win_call(origin, function()
      vim.cmd("normal! zvzz")
    end)
  end)

  if shown and close_after then
    local jumped = pcall(function()
      close_list(list_win)
      if vim.api.nvim_win_is_valid(origin) then
        vim.api.nvim_set_current_win(origin)
      end
    end)
    shown = jumped
  end
  showing_list_entry = false
  return shown
end

local qf_follow = vim.api.nvim_create_augroup("QfFollow", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  pattern = "qf",
  group = qf_follow,
  callback = function(event)
    local opts = { buffer = event.buf, silent = true }
    vim.keymap.set("n", "<CR>", function()
      show_list_entry(true)
    end, vim.tbl_extend("force", opts, { desc = "Jump and close list" }))
    vim.keymap.set("n", "q", function()
      local winid = vim.api.nvim_get_current_win()
      if list_info(winid) == nil then
        return
      end
      close_list(winid)
    end, vim.tbl_extend("force", opts, { desc = "Close list" }))
    vim.keymap.set("n", "<C-j>", "j", vim.tbl_extend("force", opts, { desc = "Next list item" }))
    vim.keymap.set("n", "<C-k>", "k", vim.tbl_extend("force", opts, { desc = "Previous list item" }))

    vim.api.nvim_clear_autocmds({ group = qf_follow, buffer = event.buf })
    vim.api.nvim_create_autocmd("CursorMoved", {
      buffer = event.buf,
      group = qf_follow,
      callback = function()
        show_list_entry(false)
      end,
    })
  end,
})

map("n", "<leader>n", ":bn<CR>", "Next buffer")
map("n", "<leader>b", ":bp<CR>", "Previous buffer")
-- visual mode remaps

--ability to paste without losing current vim reg content
map("x", "<leader>p", '"_dP', "Paste without overwriting register")

-- ability to copy to system clipboard vim code
map("v", "<leader>y", '"+y', "Yank to clipboard")

--ability to move in visual mode selected line down
map("v", "J", ":m '>+1<CR>gv=gv", "Move selection down")

--ability to move in visual mode selected line up
map("v", "K", ":m '<-2<CR>gv=gv", "Move selection up")

-- remap toggle folding to space space

map("n", "<leader><leader>", ":exe 'normal! za'<CR>", "Toggle fold")

-- Bottom terminal, same session each time. Ctrl+` never reaches nvim from a
-- terminal emulator, so Ctrl+\ is the key that actually arrives.
-- Ctrl+w z grows that split to nearly the full height and shrinks it back.
-- Ctrl+j / Ctrl+k scroll a long agent reply; i or a returns to the prompt.
local terminal = { buf = nil, zoomed = false }
local TERMINAL_HEIGHT = 12

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

-- Directory of the file in the current window. :terminal otherwise inherits
-- Neovim's launch directory, which stays at the project root.
local function buffer_directory()
  local name = vim.api.nvim_buf_get_name(0)
  if name == "" then
    return vim.fn.getcwd()
  end
  if vim.fn.isdirectory(name) == 1 then
    return vim.fn.fnamemodify(name, ":p")
  end
  local dir = vim.fn.fnamemodify(name, ":p:h")
  if vim.fn.isdirectory(dir) == 0 then
    return vim.fn.getcwd()
  end
  return dir
end

local function terminal_max_height()
  return math.max(TERMINAL_HEIGHT, vim.o.lines - 2)
end

local function terminal_split_height()
  if terminal.zoomed then
    return terminal_max_height()
  end
  return TERMINAL_HEIGHT
end

-- Half the window, so a short split and a zoomed one both move by a readable step.
local function scroll_terminal_keys(direction)
  local count = math.max(1, math.floor(vim.api.nvim_win_get_height(0) / 2))
  local motion = direction > 0 and "j" or "k"
  if vim.fn.mode() == "t" then
    return "<C-\\><C-n>" .. count .. motion
  end
  return count .. motion
end

local function bind_terminal_buffer(buf)
  local scroll_opts = { buffer = buf, expr = true, silent = true, replace_keycodes = true }
  vim.keymap.set("n", "<C-j>", function()
    return scroll_terminal_keys(1)
  end, vim.tbl_extend("force", scroll_opts, { desc = "Scroll terminal down" }))
  vim.keymap.set("n", "<C-k>", function()
    return scroll_terminal_keys(-1)
  end, vim.tbl_extend("force", scroll_opts, { desc = "Scroll terminal up" }))
end

local function prepare_terminal_window()
  vim.wo.number = false
  vim.wo.relativenumber = false
  vim.wo.signcolumn = "no"
  -- Global scrolloff is 8, which pins a short terminal to the last lines.
  vim.wo.scrolloff = 0
end

local function toggle_terminal()
  local win = terminal_window()
  if win then
    vim.api.nvim_win_hide(win)
    return
  end

  local dir = buffer_directory()
  vim.cmd("botright " .. terminal_split_height() .. "split")
  if terminal_running(terminal.buf) then
    vim.api.nvim_win_set_buf(0, terminal.buf)
  else
    vim.cmd.lcd(dir)
    vim.cmd("terminal")
    terminal.buf = vim.api.nvim_get_current_buf()
    vim.bo.buflisted = false
    vim.bo.scrollback = 100000
  end

  bind_terminal_buffer(vim.api.nvim_get_current_buf())
  prepare_terminal_window()
  vim.cmd("startinsert")
end

local function toggle_terminal_zoom()
  local win = terminal_window()
  if not win then
    return
  end

  terminal.zoomed = not terminal.zoomed
  vim.api.nvim_win_set_height(win, terminal_split_height())
end

map({ "n", "i", "t" }, "<C-\\>", toggle_terminal, "Toggle terminal", { noremap = true, silent = true, nowait = true })
map({ "n", "i", "t" }, "<C-`>", toggle_terminal, "Toggle terminal", { noremap = true, silent = true, nowait = true })
map({ "n", "t" }, "<C-w>z", toggle_terminal_zoom, "Maximize or minimize terminal")
map("t", "<C-j>", function()
  return scroll_terminal_keys(1)
end, "Scroll terminal down", { expr = true, replace_keycodes = true })
map("t", "<C-k>", function()
  return scroll_terminal_keys(-1)
end, "Scroll terminal up", { expr = true, replace_keycodes = true })

-- space+l+o starts the lofi stream, and the same keys stop it.
-- mpv is detached, so the music keeps playing after Neovim exits.
local lofi_url = "https://www.youtube.com/watch?v=rFZHOHl-L8A"
local lofi_pid_file = vim.fn.stdpath("state") .. "/lofi.pid"

local function lofi_pid()
  if vim.fn.filereadable(lofi_pid_file) == 0 then
    return nil
  end

  local pid = tonumber(vim.fn.readfile(lofi_pid_file)[1])
  if not pid then
    vim.fn.delete(lofi_pid_file)
    return nil
  end

  local name = vim.trim(vim.fn.system({ "ps", "-p", tostring(pid), "-o", "comm=" }))
  if vim.v.shell_error ~= 0 or name ~= "mpv" then
    vim.fn.delete(lofi_pid_file)
    return nil
  end

  return pid
end

local function toggle_lofi()
  local pid = lofi_pid()
  if pid then
    vim.fn.system({ "kill", tostring(pid) })
    vim.fn.delete(lofi_pid_file)
    vim.notify("Lofi stopped")
    return
  end

  local job = vim.fn.jobstart({
    "mpv",
    "--no-video",
    "--really-quiet",
    "--no-terminal",
    lofi_url,
  }, { detach = true })

  if job <= 0 then
    vim.notify("Could not start mpv", vim.log.levels.ERROR)
    return
  end

  vim.fn.writefile({ tostring(vim.fn.jobpid(job)) }, lofi_pid_file)
  vim.notify("Lofi started")
end

map("n", "<leader>lo", toggle_lofi, "Toggle lofi radio")

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
