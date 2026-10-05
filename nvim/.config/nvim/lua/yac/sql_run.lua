-- Runs the statement under the cursor with the mysql client and keeps the
-- rows in a split on the right. sqls itself answers "Query OK, 0 rows
-- affected" whenever the statement does not start with SELECT, which drops
-- the result of a commented query.
local M = {}

local RESULT = "sql-results"

local function result_buffer()
  -- "-" would be a quantifier in a Lua pattern, so the lookup goes through Vim.
  local nr = vim.fn.bufnr(RESULT .. "$")
  if nr ~= -1 and vim.api.nvim_buf_is_valid(nr) then
    return nr
  end
end

local function result_window(bufnr)
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win) == bufnr then
      return win
    end
  end
end

local function open(bufnr, source)
  local width = math.max(48, math.floor(vim.o.columns * 0.42))
  vim.cmd("botright " .. width .. "vsplit")
  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(win, bufnr)
  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.wo[win].signcolumn = "no"
  vim.wo[win].wrap = false
  vim.wo[win].winbar = " SQL"
  if source and vim.api.nvim_win_is_valid(source) and source ~= win then
    vim.api.nvim_set_current_win(source)
  end
end

local function show(source, text)
  local lines = vim.split((text or ""):gsub("\n$", ""), "\n", { plain = true })
  local bufnr = result_buffer()
  if not bufnr then
    bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(bufnr, RESULT)
    vim.bo[bufnr].bufhidden = "hide"
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
    vim.bo[bufnr].filetype = "sqls_output"
    open(bufnr, source)
    return
  end

  vim.bo[bufnr].readonly = false
  vim.bo[bufnr].modifiable = true
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.bo[bufnr].modifiable = false
  vim.bo[bufnr].readonly = true
  vim.bo[bufnr].modified = false
  if not result_window(bufnr) then
    open(bufnr, source)
  end
end

local function run(source, sql)
  local connection = require("yac.sql_explain").connection(vim.api.nvim_get_current_buf())
  if not connection then
    vim.notify("No MySQL connection in config.yml", vim.log.levels.WARN)
    return
  end

  vim.system({
    "mysql",
    "--table",
    "--host=" .. (connection.host or "127.0.0.1"),
    "--port=" .. (connection.port or "3306"),
    "--user=" .. (connection.user or ""),
    "--database=" .. (connection.dbName or ""),
    "--default-character-set=utf8mb4",
  }, {
    stdin = sql,
    env = { MYSQL_PWD = connection.passwd or "" },
    text = true,
  }, function(result)
    local text = result.stdout or ""
    if result.code ~= 0 then
      text = (result.stderr or ""):gsub("mysql: %[Warning%][^\n]*\n", "")
      if text == "" then
        text = result.stdout or ""
      end
    end
    vim.schedule(function()
      if source and not vim.api.nvim_win_is_valid(source) then
        source = nil
      end
      show(source, text)
    end)
  end)
end

-- line1 and line2 are 1-based and inclusive, like a visual selection.
function M.lines(line1, line2)
  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, line1 - 1, line2, false)
  run(vim.api.nvim_get_current_win(), table.concat(lines, "\n"))
end

function M.current()
  local bufnr = vim.api.nvim_get_current_buf()
  local row = vim.api.nvim_win_get_cursor(0)[1] - 1
  local statement = require("yac.sql_explain").at(bufnr, row)
  if not statement then
    vim.notify("No SQL statement under the cursor", vim.log.levels.WARN)
    return
  end
  run(vim.api.nvim_get_current_win(), statement.text)
end

return M
