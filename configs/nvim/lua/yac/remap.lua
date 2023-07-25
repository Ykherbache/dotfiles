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

--improve controle+d (make movement centred)
vim.keymap.set("n", "<C-d>", "<C-d>zz", opts)

--improve controle+u (make movement centred)
vim.keymap.set("n", "<C-u>", "<C-u>zz", opts)

--move to next occurence but keep it centred in screen
vim.keymap.set("n", "<n>", "nzzzv", opts)

--move to prev occurence but keep it centred in screen
vim.keymap.set("n", "<N>", "Nzzzv", opts)

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
