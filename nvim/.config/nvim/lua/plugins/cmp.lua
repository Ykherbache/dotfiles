return {
  "hrsh7th/nvim-cmp",
  dependencies = {
    "L3MON4D3/LuaSnip",
    "onsails/lspkind.nvim",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-nvim-lsp",
    "zbirenbaum/copilot-cmp",
  },
  config = function()
    local cmp = require("cmp")
    local lspkind = require("lspkind")

    local function complete_or_next()
      if cmp.visible() then
        cmp.select_next_item()
      else
        cmp.complete()
      end
    end

    cmp.setup({
      snippet = {
        expand = function(args)
          require("luasnip").lsp_expand(args.body)
        end,
      },
      mapping = cmp.mapping.preset.insert({
        ["<C-d>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-n>"] = cmp.mapping(complete_or_next, { "i", "s" }),
        -- macOS keeps Ctrl-Space for input-source switching, so it never reaches Neovim.
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-@>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.close(),
        ["<CR>"] = cmp.mapping.confirm({
          behavior = cmp.ConfirmBehavior.Replace,
          select = true,
        }),
      }),
      sources = cmp.config.sources({
        { name = "copilot" },
        { name = "nvim_lsp" },
        { name = "buffer" },
      }),
      formatting = {
        format = lspkind.cmp_format({
          with_text = false,
          maxwidth = 50,
          symbol_map = { Copilot = "" },
        }),
      },
    })

    cmp.setup.filetype("TelescopePrompt", {
      enabled = false,
    })

    vim.opt.completeopt = { "menuone", "noinsert", "noselect" }
    vim.cmd("highlight! default link CmpItemKind CmpItemMenuDefault")
  end,
}
