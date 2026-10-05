local prettier_filetypes = {
  "css",
  "javascript",
  "javascriptreact",
  "typescript",
  "typescriptreact",
  "json",
  "scss",
  "less",
}

return {
  {
    "stevearc/conform.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason").setup()
      local registry = require("mason-registry")

      local function install_tools()
        for _, tool in ipairs({ "prettierd", "eslint_d" }) do
          local ok, pkg = pcall(registry.get_package, tool)
          if ok and not pkg:is_installed() and not pkg:is_installing() then
            pkg:install()
          end
        end
      end

      registry.refresh(function(success)
        if success then
          install_tools()
        end
      end)

      local formatters_by_ft = {}
      for _, ft in ipairs(prettier_filetypes) do
        formatters_by_ft[ft] = { "prettierd" }
      end

      require("conform").setup({
        formatters_by_ft = formatters_by_ft,
        format_on_save = function(bufnr)
          if vim.b[bufnr].disable_autoformat then
            return
          end
          return { timeout_ms = 500, lsp_format = "never" }
        end,
      })

      vim.api.nvim_create_user_command("DisableLspFormatting", function()
        vim.b.disable_autoformat = true
        pcall(vim.api.nvim_clear_autocmds, { group = "Format", buffer = 0 })
      end, { nargs = 0 })
    end,
  },
  {
    "mfussenegger/nvim-lint",
    config = function()
      local lint = require("lint")

      local eslint = lint.linters.eslint_d
      if eslint and type(eslint.parser) == "function" then
        local parse = eslint.parser
        eslint.parser = function(output, bufnr)
          local diagnostics = parse(output, bufnr)
          for _, diagnostic in ipairs(diagnostics) do
            local code = diagnostic.code or ""
            diagnostic.message = ("[eslint] %s\n(%s)"):format(diagnostic.message, code)
          end
          return diagnostics
        end
      end

      lint.linters_by_ft = {
        javascript = { "eslint_d" },
        javascriptreact = { "eslint_d" },
        typescript = { "eslint_d" },
        typescriptreact = { "eslint_d" },
        fish = { "fish" },
        php = { "php" },
      }

      vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost" }, {
        callback = function()
          lint.try_lint()
        end,
      })

      local php_lint_timer = vim.uv.new_timer()
      local function schedule_php_lint(bufnr)
        php_lint_timer:stop()
        php_lint_timer:start(400, 0, vim.schedule_wrap(function()
          if not vim.api.nvim_buf_is_valid(bufnr) or vim.bo[bufnr].filetype ~= "php" then
            return
          end
          vim.api.nvim_buf_call(bufnr, function()
            lint.try_lint()
          end)
        end))
      end

      vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
        callback = function(args)
          if vim.bo[args.buf].filetype ~= "php" then
            return
          end
          schedule_php_lint(args.buf)
        end,
      })
    end,
  },
}
