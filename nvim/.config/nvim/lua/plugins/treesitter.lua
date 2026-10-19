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
      "vue",
      "lua",
      "vim",
      "go",
      "rust",
      "sql",
      "python",
    }

    require("nvim-treesitter").install(parsers)
    vim.treesitter.language.register("tsx", { "javascriptreact", "typescriptreact", "typescript.tsx" })
    vim.treesitter.language.register("json", "jsonc")
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
        "jsonc",
        "yaml",
        "css",
        "html",
        "vue",
        "lua",
        "vim",
        "go",
        "rust",
        "sql",
        "python",
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
