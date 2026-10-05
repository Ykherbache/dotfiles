return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "hrsh7th/cmp-nvim-lsp",
  },
  config = function()
    require("mason").setup()

    local capabilities = require("cmp_nvim_lsp").default_capabilities()

    local function on_attach(_, bufnr)
      local opts = { buffer = bufnr, noremap = true, silent = true }

      vim.keymap.set("n", "gd", function()
        vim.lsp.buf.definition()
      end, opts)
      vim.keymap.set("n", "gD", function()
        vim.lsp.buf.declaration()
      end, opts)
      vim.keymap.set("n", "gi", function()
        vim.lsp.buf.implementation()
      end, opts)
      vim.keymap.set("n", "<F4>", function()
        vim.lsp.buf.code_action()
      end, opts)
      vim.keymap.set("n", "gr", "<cmd>Telescope lsp_references<cr>", { buffer = true })
      vim.keymap.set("n", "<leader>vws", function()
        vim.lsp.buf.workspace_symbol()
      end, opts)
      vim.keymap.set("n", "<leader>vd", function()
        vim.diagnostic.open_float()
      end, opts)
      vim.keymap.set("n", "[d", function()
        vim.diagnostic.goto_next()
      end, opts)
      vim.keymap.set("n", "]d", function()
        vim.diagnostic.goto_prev()
      end, opts)
      vim.keymap.set("n", "<leader>vca", function()
        vim.lsp.buf.code_action()
      end, opts)
      vim.keymap.set("n", "<leader>vrr", function()
        vim.lsp.buf.references()
      end, opts)
      vim.keymap.set("i", "<C-h>", function()
        vim.lsp.buf.signature_help()
      end, opts)
    end

    local format_group = vim.api.nvim_create_augroup("Format", { clear = true })

    local function enable_format_on_save(bufnr)
      vim.api.nvim_clear_autocmds({ group = format_group, buffer = bufnr })
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = format_group,
        buffer = bufnr,
        callback = function()
          if vim.b[bufnr].disable_autoformat then
            return
          end
          vim.lsp.buf.format({ bufnr = bufnr })
        end,
      })
    end

    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if not client then
          return
        end
        on_attach(client, args.buf)
        if client.name == "lua_ls" then
          enable_format_on_save(args.buf)
        end
      end,
    })

    local function rename_symbol()
      local clients = vim.lsp.get_clients({
        bufnr = 0,
        method = "textDocument/rename",
      })
      if #clients == 0 then
        vim.notify("No language server with rename is attached to this file.", vim.log.levels.WARN)
        return
      end
      -- Let the mapping finish so the "New Name:" prompt can draw.
      vim.schedule(function()
        vim.lsp.buf.rename()
      end)
    end

    local rename_opts = { noremap = true, desc = "Rename symbol" }
    vim.keymap.set("n", "<F2>", rename_symbol, rename_opts)
    vim.keymap.set("n", "<leader>rn", rename_symbol, rename_opts)
    vim.keymap.set("n", "<leader>vrn", rename_symbol, rename_opts)

    vim.lsp.config("ts_ls", {
      capabilities = capabilities,
      filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
      cmd = { "typescript-language-server", "--stdio" },
    })

    vim.lsp.config("lua_ls", {
      capabilities = capabilities,
      settings = {
        Lua = {
          diagnostics = {
            globals = { "vim" },
          },
          workspace = {
            library = vim.api.nvim_get_runtime_file("", true),
            checkThirdParty = false,
          },
        },
      },
    })

    vim.lsp.config("cssls", { capabilities = capabilities })
    vim.lsp.config("astro", { capabilities = capabilities })
    vim.lsp.config("phpactor", { capabilities = capabilities })

    -- Attaches only when the project root contains config.yml.
    vim.lsp.config("sqls", {
      capabilities = capabilities,
      workspace_required = true,
      cmd = { "sqls", "-config", "config.yml" },
    })

    -- Attaches only when the project root contains postgres-language-server.jsonc.
    vim.lsp.config("postgres_lsp", {
      capabilities = capabilities,
    })

    if vim.fn.executable("flow") == 1 then
      vim.lsp.config("flow", { capabilities = capabilities })
      vim.lsp.enable("flow")
    end

    if vim.fn.executable("sourcekit-lsp") == 1 then
      vim.lsp.config("sourcekit", { capabilities = capabilities })
      vim.lsp.enable("sourcekit")
    end

    require("mason-lspconfig").setup({
      ensure_installed = { "ts_ls", "lua_ls", "cssls", "astro", "phpactor", "sqls", "postgres_lsp" },
    })

    vim.lsp.enable({ "ts_ls", "lua_ls", "cssls", "astro", "phpactor", "sqls", "postgres_lsp" })

    vim.diagnostic.config({
      virtual_text = {
        prefix = "●",
      },
      update_in_insert = true,
      float = {
        source = "always",
      },
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = " ",
          [vim.diagnostic.severity.WARN] = " ",
          [vim.diagnostic.severity.HINT] = " ",
          [vim.diagnostic.severity.INFO] = " ",
        },
      },
    })
  end,
}
