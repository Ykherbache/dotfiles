return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope-file-browser.nvim",
  },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")
    local builtin = require("telescope.builtin")
    local fb_actions = telescope.extensions.file_browser.actions

    local function telescope_buffer_dir()
      return vim.fn.expand("%:p:h")
    end

    local lsd_preview_paths = {}

    local function lsd_file_previewer(opts)
      opts = opts or {}
      local from_entry = require("telescope.from_entry")
      local Path = require("plenary.path")
      local previewers = require("telescope.previewers")
      local conf = require("telescope.config").values
      local cwd = opts.cwd or vim.uv.cwd()

      return previewers.new_buffer_previewer({
        title = "File Preview",
        dyn_title = function(_, entry)
          return Path:new(from_entry.path(entry, false, false)):normalize(cwd)
        end,
        get_buffer_by_name = function(_, entry)
          return from_entry.path(entry, false, false)
        end,
        define_preview = function(self, entry)
          local path = from_entry.path(entry, true, false)
          local bufnr = self.state.bufnr
          if path == nil or path == "" or not bufnr then
            return
          end

          if vim.fn.isdirectory(path) == 1 then
            lsd_preview_paths[bufnr] = path
            vim.system({
              "lsd",
              "--group-directories-first",
              "--almost-all",
              "--icon=always",
              "--color=never",
              "-1",
              "--",
              path,
            }, { text = true }, function(result)
              vim.schedule(function()
                if not vim.api.nvim_buf_is_valid(bufnr) or lsd_preview_paths[bufnr] ~= path then
                  return
                end
                local lines = {}
                if result.code == 0 then
                  lines = vim.split(result.stdout or "", "\n", { trimempty = true })
                elseif result.stderr and result.stderr ~= "" then
                  lines = vim.split(result.stderr, "\n", { trimempty = true })
                end
                vim.bo[bufnr].modifiable = true
                vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
              end)
            end)
            return
          end

          conf.buffer_previewer_maker(path, bufnr, {
            bufname = self.state.bufname,
            winid = self.state.winid,
            preview = opts.preview,
          })
        end,
      })
    end

    local function clear_prompt_close(prompt_bufnr)
      pcall(vim.api.nvim_clear_autocmds, {
        group = "PickerInsert",
        event = "BufLeave",
        buffer = prompt_bufnr,
      })
    end

    -- Telescope closes the picker when the prompt buffer is left. Entering the
    -- preview has to skip that, then arm it again once focus is back.
    local function arm_prompt_close(prompt_bufnr)
      if not vim.api.nvim_buf_is_valid(prompt_bufnr) then
        return
      end
      clear_prompt_close(prompt_bufnr)
      vim.api.nvim_create_autocmd("BufLeave", {
        buffer = prompt_bufnr,
        group = "PickerInsert",
        nested = true,
        once = true,
        callback = function()
          require("telescope.pickers").on_close_prompt(prompt_bufnr)
        end,
      })
    end

    local function edit_in_preview(prompt_bufnr)
      local picker = action_state.get_current_picker(prompt_bufnr)
      local entry = action_state.get_selected_entry()
      if not entry or entry.is_dir or not entry.path or entry.path == "" then
        return
      end
      if not picker.preview_win or not vim.api.nvim_win_is_valid(picker.preview_win) then
        return
      end

      local line = vim.api.nvim_win_get_cursor(picker.preview_win)[1]
      clear_prompt_close(prompt_bufnr)
      vim.api.nvim_set_current_win(picker.preview_win)
      if not vim.api.nvim_win_is_valid(picker.preview_win) then
        arm_prompt_close(prompt_bufnr)
        return
      end

      local opened = pcall(vim.cmd, "edit " .. vim.fn.fnameescape(entry.path))
      if not opened or not vim.api.nvim_win_is_valid(picker.preview_win) then
        if picker.prompt_win and vim.api.nvim_win_is_valid(picker.prompt_win) then
          vim.api.nvim_set_current_win(picker.prompt_win)
        end
        arm_prompt_close(prompt_bufnr)
        return
      end
      vim.cmd("stopinsert")

      local last = vim.api.nvim_buf_line_count(0)
      if line > last then
        line = last
      end
      if line < 1 then
        line = 1
      end
      vim.api.nvim_win_set_cursor(0, { line, 0 })

      local bufnr = vim.api.nvim_get_current_buf()
      vim.keymap.set("n", "<Esc>", function()
        pcall(vim.keymap.del, "n", "<Esc>", { buffer = bufnr })
        if picker.prompt_win and vim.api.nvim_win_is_valid(picker.prompt_win) then
          vim.api.nvim_set_current_win(picker.prompt_win)
          vim.cmd("stopinsert")
          arm_prompt_close(prompt_bufnr)
        end
      end, { buffer = bufnr, desc = "Return to file browser" })
    end

    telescope.setup({
      defaults = {
        file_previewer = function(opts)
          opts = opts or {}
          if vim.fn.executable("lsd") == 1 and type(opts.preview) == "table" and opts.preview.lsd then
            return lsd_file_previewer(opts)
          end
          return require("telescope.previewers").vim_buffer_cat.new(opts)
        end,
        mappings = {
          i = {
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,
          },
          n = {
            ["q"] = actions.close,
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,
          },
        },
      },
      extensions = {
        file_browser = {
          theme = "dropdown",
          hijack_netrw = true,
          preview = { lsd = true, ls_short = true },
          mappings = {
            ["i"] = {
              ["<Tab>"] = edit_in_preview,
              ["<C-w>"] = function()
                vim.cmd("normal vbd")
              end,
            },
            ["n"] = {
              ["<Tab>"] = edit_in_preview,
              -- Same as netrw: f = new file (trailing / in the prompt makes a directory).
              ["f"] = fb_actions.create,
              ["N"] = fb_actions.create,
              ["h"] = fb_actions.goto_parent_dir,
              ["/"] = function()
                vim.cmd("startinsert")
              end,
            },
          },
        },
      },
    })
    telescope.load_extension("file_browser")

    local function find_files()
      builtin.find_files({
        no_ignore = false,
        hidden = true,
      })
    end

    local keymap_displayer = require("telescope.pickers.entry_display").create({
      separator = "  ",
      items = {
        { width = 40 },
        { remaining = true },
      },
    })

    local function keymap_entry(entry)
      local shortcut = entry.mode .. " " .. vim.fn.keytrans(entry.lhs)
      return {
        value = entry,
        ordinal = entry.desc .. " " .. shortcut,
        display = function()
          return keymap_displayer({ entry.desc, shortcut })
        end,
      }
    end

    local function show_keybindings()
      builtin.keymaps({
        prompt_title = "Keybindings",
        previewer = false,
        modes = { "n", "v", "x", "i", "t" },
        show_plug = false,
        filter = function(keymap)
          return keymap.desc ~= nil and keymap.desc ~= ""
        end,
        entry_maker = keymap_entry,
      })
    end

    vim.keymap.set("n", ";f", find_files, { desc = "Find files" })
    vim.keymap.set("n", "<C-p>", find_files, { desc = "Find files" })
    vim.keymap.set("n", ";r", function()
      builtin.live_grep()
    end, { desc = "Live grep" })
    vim.keymap.set("n", "\\\\", function()
      builtin.buffers()
    end, { desc = "Buffers" })
    vim.keymap.set("n", ";t", function()
      builtin.help_tags()
    end, { desc = "Help tags" })
    vim.keymap.set("n", ";;", function()
      builtin.resume()
    end, { desc = "Resume Telescope" })
    vim.keymap.set("n", ";e", function()
      builtin.diagnostics()
    end, { desc = "Diagnostics" })
    vim.keymap.set("n", "sf", function()
      telescope.extensions.file_browser.file_browser({
        path = "%:p:h",
        cwd = telescope_buffer_dir(),
        respect_gitignore = false,
        hidden = true,
        grouped = true,
        initial_mode = "normal",
        layout_strategy = "horizontal",
        layout_config = {
          width = 0.8,
          height = 0.8,
          preview_width = 0.55,
          prompt_position = "top",
        },
      })
    end, { desc = "File browser" })
    vim.keymap.set("n", "<C-y>", show_keybindings, { desc = "Show keybindings" })
  end,
}
