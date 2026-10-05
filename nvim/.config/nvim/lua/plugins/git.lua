return {
  "dinhhuy258/git.nvim",
  config = function()
    require("git").setup({
      keymaps = {
        blame = "<Leader>gb",
        browse = "<Leader>go",
      },
    })
  end,
}
