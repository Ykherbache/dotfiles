return {
  "Ykherbache/tomorrow-night-blue",
  config = function()
    -- @theme blocks are mostly custom properties. Those captures use @variable,
    -- which this colorscheme leaves as NvimLightGrey2, so the block looks uncolored.
    local group = vim.api.nvim_create_augroup("CssVariableHighlight", { clear = true })
    vim.api.nvim_create_autocmd("ColorScheme", {
      group = group,
      callback = function()
        vim.api.nvim_set_hl(0, "@variable.css", { fg = "#99ffff", ctermfg = 123 })
      end,
    })
    vim.cmd.colorscheme("Tomorrow-Night-Blue")
  end,
}
