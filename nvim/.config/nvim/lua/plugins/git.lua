return {
  "dinhhuy258/git.nvim",
  config = function()
    require("git").setup({
      keymaps = {
        blame = "<Leader>gb",
        browse = "<Leader>go",
      },
    })

    local git_opts = { noremap = true, silent = true }
    vim.keymap.set(
      "n",
      "<leader>gb",
      "<CMD>lua require('git.blame').blame()<CR>",
      vim.tbl_extend("force", git_opts, { desc = "Git blame" })
    )
    vim.keymap.set(
      "n",
      "<leader>go",
      "<CMD>lua require('git.browse').open(false)<CR>",
      vim.tbl_extend("force", git_opts, { desc = "Git browse" })
    )
    vim.keymap.set(
      "x",
      "<leader>go",
      ":<C-u> lua require('git.browse').open(true)<CR>",
      vim.tbl_extend("force", git_opts, { desc = "Git browse" })
    )
  end,
}
