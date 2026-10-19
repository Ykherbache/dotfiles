local prettier_filetypes = {
  "css",
  "json",
  "scss",
  "less",
}

local eslint_filetypes = {
  "javascript",
  "javascriptreact",
  "typescript",
  "typescriptreact",
  "vue",
}

local eslint_config_markers = {
  "eslint.config.js",
  "eslint.config.mjs",
  "eslint.config.cjs",
  "eslint.config.ts",
}

local function js_formatter(bufnr)
  if vim.fs.root(bufnr, eslint_config_markers) then
    return { "eslint_d" }
  end
  return { "prettierd" }
end

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
      for _, ft in ipairs(eslint_filetypes) do
        formatters_by_ft[ft] = js_formatter
      end

      require("conform").setup({
        formatters_by_ft = formatters_by_ft,
        format_on_save = function(bufnr)
          if vim.b[bufnr].disable_autoformat then
            return
          end
          return { timeout_ms = 3000, lsp_format = "never" }
        end,
      })

      -- Same split as save: conform when it has a formatter, otherwise the Lua server.
      -- An explicit format still runs when autoformat is disabled for the buffer.
      vim.keymap.set("n", "<leader>f", function()
        local bufnr = vim.api.nvim_get_current_buf()
        local conform = require("conform")
        if #conform.list_formatters(bufnr) > 0 then
          conform.format({ async = true, bufnr = bufnr, lsp_format = "never" })
          return
        end
        if vim.bo[bufnr].filetype == "lua" then
          vim.lsp.buf.format({ async = true, bufnr = bufnr })
          return
        end
        vim.notify("No formatter for this file", vim.log.levels.WARN)
      end, { desc = "Format file" })

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
        vue = { "eslint_d" },
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
