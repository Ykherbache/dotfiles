return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  build = ":TSUpdate",
  dependencies = {
    "windwp/nvim-ts-autotag",
  },
  config = function()
    local parsers = {
      "tsx",
      "javascript",
      "typescript",
      "toml",
      "fish",
      "php",
      "json",
      "yaml",
      "css",
      "html",
      "lua",
      "vim",
      "go",
      "rust",
    }

    require("nvim-treesitter").install(parsers)
    vim.treesitter.language.register("tsx", { "javascriptreact", "typescriptreact", "typescript.tsx" })
    require("nvim-ts-autotag").setup({})

    vim.api.nvim_create_autocmd("FileType", {
      pattern = {
        "javascript",
        "javascriptreact",
        "typescript",
        "typescriptreact",
        "typescript.tsx",
        "toml",
        "fish",
        "php",
        "json",
        "yaml",
        "css",
        "html",
        "lua",
        "vim",
        "go",
        "rust",
      },
      callback = function()
        if not pcall(vim.treesitter.start) then
          return
        end
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })
  end,
}
