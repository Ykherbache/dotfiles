return {
  "nanotee/sqls.nvim",
  config = function()
    require("yac.sql_explain").setup()

    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if not client or client.name ~= "sqls" then
          return
        end

        local opts = { buffer = args.buf, silent = true }
        -- space+e runs the statement under the cursor. A visual selection runs those lines.
        vim.keymap.set("n", "<leader>e", function()
          require("yac.sql_run").current()
        end, opts)
        vim.keymap.set("x", "<leader>e", function()
          local first = vim.fn.getpos("v")[2]
          local last = vim.fn.getcurpos()[2]
          if first > last then
            first, last = last, first
          end
          require("yac.sql_run").lines(first, last)
        end, opts)
      end,
    })
  end,
}
