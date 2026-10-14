return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope-file-browser.nvim",
  },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")
    local builtin = require("telescope.builtin")
    local fb_actions = telescope.extensions.file_browser.actions

    local function telescope_buffer_dir()
      return vim.fn.expand("%:p:h")
    end

    telescope.setup({
      defaults = {
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
          mappings = {
            ["i"] = {
              ["<C-w>"] = function()
                vim.cmd("normal vbd")
              end,
            },
            ["n"] = {
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
        previewer = false,
        initial_mode = "normal",
        layout_config = { height = 40 },
      })
    end, { desc = "File browser" })
    vim.keymap.set("n", "<C-y>", show_keybindings, { desc = "Show keybindings" })
  end,
}
