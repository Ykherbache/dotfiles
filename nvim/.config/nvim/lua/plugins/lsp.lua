return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "hrsh7th/cmp-nvim-lsp",
    "b0o/SchemaStore.nvim",
  },
  config = function()
    require("mason").setup()

    local capabilities = require("cmp_nvim_lsp").default_capabilities()

    local find_tailwind_css
    local goto_tailwind_class

    local function on_attach(_, bufnr)
      local opts = { buffer = bufnr, noremap = true, silent = true }

      local function map(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, vim.tbl_extend("force", opts, { desc = desc }))
      end

      map("n", "<C-t>", function()
        vim.lsp.buf.hover()
      end, "Hover")
      map("n", "gd", function()
        if not goto_tailwind_class() then
          vim.lsp.buf.definition()
        end
      end, "Go to definition")
      map("n", "gD", function()
        vim.lsp.buf.declaration()
      end, "Go to declaration")
      map("n", "gi", function()
        vim.lsp.buf.implementation()
      end, "Go to implementation")
      map("n", "<F4>", function()
        vim.lsp.buf.code_action()
      end, "Code action")
      map("n", "gr", "<cmd>Telescope lsp_references<cr>", "References")
      map("n", "<leader>vws", function()
        vim.lsp.buf.workspace_symbol()
      end, "Workspace symbol")
      map("n", "<leader>vd", function()
        vim.diagnostic.open_float()
      end, "Line diagnostics")
      map("n", "[d", function()
        vim.diagnostic.goto_next()
      end, "Next diagnostic")
      map("n", "]d", function()
        vim.diagnostic.goto_prev()
      end, "Previous diagnostic")
      map("n", "<leader>vca", function()
        vim.lsp.buf.code_action()
      end, "Code action")
      map("n", "<leader>vrr", function()
        vim.lsp.buf.references()
      end, "References")
      map("i", "<C-h>", function()
        vim.lsp.buf.signature_help()
      end, "Signature help")
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

    -- Vue language server v3 forwards TypeScript work to ts_ls through this plugin.
    local vue_language_server_path = vim.fn.stdpath("data")
      .. "/mason/packages/vue-language-server/node_modules/@vue/language-server"

    vim.lsp.config("ts_ls", {
      capabilities = capabilities,
      filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue" },
      cmd = { "typescript-language-server", "--stdio" },
      init_options = {
        plugins = {
          {
            name = "@vue/typescript-plugin",
            location = vue_language_server_path,
            languages = { "vue" },
            configNamespace = "typescript",
          },
        },
      },
    })

    vim.lsp.config("vue_ls", { capabilities = capabilities })

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

    vim.lsp.config("html", { capabilities = capabilities })

    -- cssls has no Tailwind at-rules. customData makes @theme, @apply, and the
    -- rest known (hover and completion). The server only loads that file when
    -- the client sends css/customDataChanged; settings.css.customData is ignored.
    -- unknownAtRules stays ignored so a directive missing from the data file
    -- does not light up the buffer.
    local tailwind_css_data = vim.fs.joinpath(vim.fn.stdpath("config"), "lsp", "tailwind.css-data.json")
    local css_lint = {
      lint = {
        unknownAtRules = "ignore",
      },
    }
    vim.lsp.config("cssls", {
      capabilities = capabilities,
      settings = {
        css = css_lint,
        scss = css_lint,
        less = css_lint,
      },
      -- Sent before any buffer attaches. The server spreads a JSON array into
      -- arguments, so the path list has to be the single positional argument.
      on_init = function(client)
        client:notify("css/customDataChanged", { { vim.uri_from_fname(tailwind_css_data) } })
      end,
    })
    vim.lsp.config("emmet_language_server", { capabilities = capabilities })

    local skip_dirs = {
      node_modules = true,
      dist = true,
      build = true,
      [".git"] = true,
      [".next"] = true,
      [".nuxt"] = true,
      [".output"] = true,
      coverage = true,
      vendor = true,
      [".turbo"] = true,
      target = true,
    }

    -- Tailwind v4 custom utilities (text-label from --text-label) only appear once the
    -- language server is given the CSS file that holds @theme. Auto-discovery misses it
    -- when the workspace root is the monorepo rather than the frontend package.
    find_tailwind_css = function(root)
      local entries, themes = {}, {}
      local function scan(dir, depth)
        if depth > 6 then
          return
        end
        local handle = vim.uv.fs_scandir(dir)
        if not handle then
          return
        end
        while true do
          local name, typ = vim.uv.fs_scandir_next(handle)
          if not name then
            break
          end
          if not skip_dirs[name] and name:sub(1, 1) ~= "." then
            local path = vim.fs.joinpath(dir, name)
            if typ == "directory" then
              scan(path, depth + 1)
            elseif typ == "file" and name:sub(-4) == ".css" then
              local fd = io.open(path, "r")
              local chunk = fd and fd:read(8192) or ""
              if fd then
                fd:close()
              end
              local imports_tailwind = chunk:find('@import%s+["\']tailwindcss') ~= nil
              if imports_tailwind or chunk:find("@theme", 1, true) then
                local bucket = imports_tailwind and entries or themes
                bucket[#bucket + 1] = path
              end
            end
          end
        end
      end
      scan(root, 0)
      local found = #entries > 0 and entries or themes
      if #found == 0 then
        return nil
      end

      -- A package can contain a preview stylesheet plus the one the app imports.
      -- Completion has to follow the file referenced by source, otherwise the
      -- preview theme hides project utilities such as text-label.
      if #found > 1 then
        local by_name = {}
        for _, path in ipairs(found) do
          local base = vim.fs.basename(path)
          by_name[base] = by_name[base] or {}
          table.insert(by_name[base], path)
        end
        local source_ext = {
          [".ts"] = true,
          [".tsx"] = true,
          [".js"] = true,
          [".jsx"] = true,
          [".vue"] = true,
          [".svelte"] = true,
          [".astro"] = true,
        }
        local hit = {}
        local function walk_sources(dir, depth)
          if depth > 6 then
            return
          end
          local handle = vim.uv.fs_scandir(dir)
          if not handle then
            return
          end
          while true do
            local name, typ = vim.uv.fs_scandir_next(handle)
            if not name then
              break
            end
            if not skip_dirs[name] and name:sub(1, 1) ~= "." then
              local path = vim.fs.joinpath(dir, name)
              if typ == "directory" then
                walk_sources(path, depth + 1)
              elseif typ == "file" then
                local ext = name:match("%.[^.]+$")
                if ext and source_ext[ext] then
                  local fd = io.open(path, "r")
                  local chunk = fd and fd:read(65536) or ""
                  if fd then
                    fd:close()
                  end
                  for base, paths in pairs(by_name) do
                    if chunk:find(base, 1, true) then
                      for _, css_path in ipairs(paths) do
                        hit[css_path] = true
                      end
                    end
                  end
                end
              end
            end
          end
        end
        walk_sources(root, 0)
        local referenced = {}
        for _, path in ipairs(found) do
          if hit[path] then
            referenced[#referenced + 1] = path
          end
        end
        if #referenced > 0 then
          found = referenced
        end
      end
      if #found == 1 then
        return found[1]
      end
      local map = {}
      for _, path in ipairs(found) do
        local package = vim.fs.dirname(path)
        while package and vim.fs.normalize(package) ~= vim.fs.normalize(root) do
          if vim.fn.filereadable(vim.fs.joinpath(package, "package.json")) == 1 then
            break
          end
          local parent = vim.fs.dirname(package)
          if parent == package then
            break
          end
          package = parent
        end
        local glob = vim.fs.relpath(root, package)
        map[path] = glob and (glob .. "/**") or "**"
      end
      return map
    end

    local function tailwind_css_files(root)
      local found = find_tailwind_css(root)
      if type(found) == "string" then
        return { found }
      end
      if type(found) ~= "table" then
        return {}
      end
      local files = {}
      for path in pairs(found) do
        files[#files + 1] = path
      end
      table.sort(files)
      return files
    end

    local function class_token_at_cursor()
      local line = vim.api.nvim_get_current_line()
      local index = vim.api.nvim_win_get_cursor(0)[2] + 1
      if index < 1 or index > #line then
        return nil
      end
      local function is_class_char(i)
        return line:sub(i, i):match("[%w%-%_%.%[%]%(%)%:%!%/#%%+]") ~= nil
      end
      if not is_class_char(index) then
        return nil
      end
      local left = index
      while left > 1 and is_class_char(left - 1) do
        left = left - 1
      end
      local right = index
      while right < #line and is_class_char(right + 1) do
        right = right + 1
      end
      return line:sub(left, right)
    end

    local function utility_from_token(token)
      local depth = 0
      local start_at = 1
      for i = 1, #token do
        local ch = token:sub(i, i)
        if ch == "[" or ch == "(" then
          depth = depth + 1
        elseif ch == "]" or ch == ")" then
          depth = depth > 0 and depth - 1 or 0
        elseif ch == ":" and depth == 0 then
          start_at = i + 1
        end
      end
      local utility = token:sub(start_at):gsub("^!", ""):gsub("!$", "")
      depth = 0
      local slash_at
      for i = 1, #utility do
        local ch = utility:sub(i, i)
        if ch == "[" or ch == "(" then
          depth = depth + 1
        elseif ch == "]" or ch == ")" then
          depth = depth > 0 and depth - 1 or 0
        elseif ch == "/" and depth == 0 then
          slash_at = i
          break
        end
      end
      if slash_at then
        local left = utility:sub(1, slash_at - 1)
        local right = utility:sub(slash_at + 1)
        local fraction = left:match("%-%d$") and right:match("^%d$")
        local opacity = right:match("^%d+$") or right:sub(1, 1) == "["
        if opacity and not fraction then
          utility = left
        end
      end
      if utility == "" or not utility:find("-", 1, true) then
        return nil
      end
      return utility
    end

    local function theme_variables(utility)
      local variables = {}
      local function add(name)
        variables[#variables + 1] = name
      end
      local function rest_of(prefix)
        local escaped = prefix:gsub("(%W)", "%%%1")
        return utility:match("^" .. escaped .. "%-(.+)$")
      end

      local rest = rest_of("text")
      if rest then
        add("--text-" .. rest)
        add("--color-" .. rest)
        return variables
      end
      rest = rest_of("bg") or rest_of("border")
      if rest then
        add("--color-" .. rest)
        return variables
      end
      rest = rest_of("font")
      if rest then
        add("--font-" .. rest)
        add("--font-weight-" .. rest)
        return variables
      end
      rest = rest_of("rounded")
      if rest then
        add("--radius-" .. rest)
        return variables
      end
      rest = rest_of("shadow")
      if rest then
        add("--shadow-" .. rest)
        return variables
      end
      rest = rest_of("animate")
      if rest then
        add("--animate-" .. rest)
        return variables
      end
      local spacing_prefixes = {
        "min-w", "max-w", "min-h", "max-h",
        "space-x", "space-y",
        "gap", "size",
        "px", "py", "pt", "pr", "pb", "pl", "p",
        "mx", "my", "mt", "mr", "mb", "ml", "m",
        "w", "h",
        "inset", "top", "right", "bottom", "left",
      }
      for _, prefix in ipairs(spacing_prefixes) do
        rest = rest_of(prefix)
        if rest then
          add("--spacing-" .. rest)
          return variables
        end
      end
      add("--" .. utility)
      return variables
    end

    local function declaration_in_file(path, utility)
      local lines = vim.fn.readfile(path)
      for _, variable in ipairs(theme_variables(utility)) do
        local pattern = vim.pesc(variable) .. "%s*:"
        for lnum, line in ipairs(lines) do
          if line:find(pattern, 1) then
            local col = line:find(variable, 1, true) or 1
            return lnum, col - 1
          end
        end
      end
      local escaped = vim.pesc(utility)
      for lnum, line in ipairs(lines) do
        local _, end_at = line:find("@utility%s+" .. escaped)
        if end_at then
          local next_ch = line:sub(end_at + 1, end_at + 1)
          if next_ch == "" or next_ch:match("%s") or next_ch == "{" then
            local col = line:find("@utility", 1, true) or 1
            return lnum, col - 1
          end
        end
      end
    end

    goto_tailwind_class = function()
      local token = class_token_at_cursor()
      local utility = token and utility_from_token(token)
      if not utility then
        return false
      end
      local clients = vim.lsp.get_clients({ bufnr = 0, name = "tailwindcss" })
      local root = clients[1] and (clients[1].root_dir or clients[1].config.root_dir)
      if not root then
        return false
      end
      for _, path in ipairs(tailwind_css_files(root)) do
        local lnum, col = declaration_in_file(path, utility)
        if lnum then
          vim.cmd("normal! m'")
          local from = vim.fn.getpos(".")
          from[1] = vim.api.nvim_get_current_buf()
          vim.fn.settagstack(vim.api.nvim_get_current_win(), {
            items = { { tagname = utility, from = from } },
          }, "t")
          vim.cmd("edit +" .. lnum .. " " .. vim.fn.fnameescape(path))
          vim.api.nvim_win_set_cursor(0, { lnum, col })
          vim.cmd("normal! zv")
          return true
        end
      end
      return false
    end

    -- Watched-file registration lets Tailwind refresh classes when the CSS entry changes.
    vim.lsp.config("tailwindcss", {
      capabilities = vim.tbl_deep_extend("force", capabilities, {
        workspace = {
          didChangeWatchedFiles = {
            dynamicRegistration = true,
          },
        },
      }),
      settings = {
        tailwindCSS = {
          includeLanguages = {
            vue = "html",
          },
          classFunctions = { "cn", "cva", "clsx", "tw" },
          classAttributes = {
            "class",
            "className",
            "class:list",
            "classList",
            "ngClass",
            ":class",
          },
        },
      },
      -- Neovim copies config.settings into the client before this callback.
      -- Reassigning the table would leave the client with the old one, so the
      -- language server would never see configFile.
      before_init = function(_, config)
        local settings = config.settings
        settings.editor = settings.editor or {}
        if settings.editor.tabSize == nil then
          settings.editor.tabSize = vim.lsp.util.get_effective_tabstop()
        end
        local css = config.root_dir and find_tailwind_css(config.root_dir)
        if not css then
          return
        end
        local tailwind = settings.tailwindCSS
        if not tailwind then
          tailwind = {}
          settings.tailwindCSS = tailwind
        end
        local experimental = tailwind.experimental
        if not experimental then
          experimental = {}
          tailwind.experimental = experimental
        end
        experimental.configFile = css
      end,
    })
    vim.lsp.config("astro", { capabilities = capabilities })
    vim.lsp.config("phpactor", { capabilities = capabilities })
    vim.lsp.config("dockerls", { capabilities = capabilities })
    vim.lsp.config("basedpyright", { capabilities = capabilities })

    -- Schema completion for tsconfig.json and tsconfig*.json.
    vim.lsp.config("jsonls", {
      capabilities = capabilities,
      settings = {
        json = {
          schemas = require("schemastore").json.schemas({
            select = { "tsconfig.json" },
          }),
          validate = { enable = true },
        },
      },
    })

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
      ensure_installed = { "ts_ls", "vue_ls", "lua_ls", "html", "cssls", "emmet_language_server", "tailwindcss", "astro", "phpactor", "sqls", "postgres_lsp", "dockerls", "jsonls", "basedpyright" },
    })

    vim.lsp.enable({ "ts_ls", "vue_ls", "lua_ls", "html", "cssls", "emmet_language_server", "tailwindcss", "astro", "phpactor", "sqls", "postgres_lsp", "dockerls", "jsonls", "basedpyright" })

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
