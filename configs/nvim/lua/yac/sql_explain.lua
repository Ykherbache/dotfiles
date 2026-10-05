-- Red marks for MySQL errors: each statement is sent to the database as
-- EXPLAIN, which checks tables, columns and syntax without running it.
-- Connection comes from the first entry of config.yml (same file as sqls).
local M = {}

local namespace = vim.api.nvim_create_namespace("sql_explain")
local checkable = { select = true, insert = true, update = true, delete = true, replace = true, with = true }

function M.connection(bufnr)
  local file = vim.fs.find("config.yml", {
    upward = true,
    path = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr)),
  })[1]
  if not file then
    return nil
  end

  local connection = {}
  for _, line in ipairs(vim.fn.readfile(file)) do
    local key, value = line:match("^%s*-?%s*(%w+):%s*(.-)%s*$")
    if key and value ~= "" then
      value = value:gsub("^'(.*)'$", "%1"):gsub('^"(.*)"$', "%1")
      if connection[key] then
        break
      end
      connection[key] = value
    end
  end

  if connection.driver ~= "mysql" then
    return nil
  end
  return connection
end

-- Splits on ';' outside quotes and comments, keeping the 0-based line where
-- each statement starts.
local function split_statements(lines)
  local text = table.concat(lines, "\n")
  local statements = {}
  local start, line, start_line = 1, 0, nil
  local quote, line_comment, block_comment = nil, false, false
  local i = 1

  local function push(stop)
    local body = text:sub(start, stop)
    if body:match("%S") then
      local leading = body:match("^%s*")
      local _, newlines = leading:gsub("\n", "")
      table.insert(statements, {
        text = vim.trim(body),
        line = start_line + newlines,
        end_line = line,
      })
    end
  end

  start_line = 0
  while i <= #text do
    local char = text:sub(i, i)
    local next_char = text:sub(i + 1, i + 1)

    if char == "\n" then
      line = line + 1
      line_comment = false
    elseif line_comment then
      -- skip
    elseif block_comment then
      if char == "*" and next_char == "/" then
        block_comment = false
        i = i + 1
      end
    elseif quote then
      if char == "\\" then
        i = i + 1
      elseif char == quote then
        quote = nil
      end
    elseif char == "'" or char == '"' or char == "`" then
      quote = char
    elseif char == "#" or (char == "-" and next_char == "-") then
      line_comment = true
    elseif char == "/" and next_char == "*" then
      block_comment = true
      i = i + 1
    elseif char == ";" then
      push(i - 1)
      start, start_line = i + 1, line
    end
    i = i + 1
  end
  push(#text)

  return statements
end

local function strip_comments(sql)
  return (sql:gsub("/%*.-%*/", " "):gsub("%-%-[^\n]*", ""):gsub("#[^\n]*", ""))
end

-- MySQL names the bad table or column, but not where it sits in the statement.
local function blamed_token(body)
  local table_name = body:match("Table '.-%.([^']+)'") or body:match("[Tt]able '([^']+)'")
  if table_name then
    return table_name
  end

  local column = body:match("[Cc]olumn '([^']+)'")
  if column then
    return column:match("([^%.]+)$")
  end

  local near = body:match("near '([^']+)'")
  if near then
    return near:match("^[%w_]+")
  end
end

local function is_ident(char)
  return char ~= "" and char:match("[%w_]") ~= nil
end

-- Byte column of `token` inside the statement, so the underline sits on that word.
local function find_token(statement, token)
  if not token or token == "" then
    return nil
  end

  local from = 1
  while from <= #statement.text do
    local start_at, stop_at = statement.text:find(token, from, true)
    if not start_at then
      return nil
    end

    local before = statement.text:sub(start_at - 1, start_at - 1)
    local after = statement.text:sub(stop_at + 1, stop_at + 1)
    if not is_ident(before) and not is_ident(after) then
      local prefix = statement.text:sub(1, start_at - 1)
      local _, newlines = prefix:gsub("\n", "")
      local line_start = prefix:match(".*\n()") or 1
      return statement.line + newlines, start_at - line_start, stop_at - line_start + 1
    end
    from = start_at + 1
  end
end

local function place(statement, body)
  local lnum, col, end_col = find_token(statement, blamed_token(body))
  if lnum then
    return lnum, col, end_col
  end

  local reported = body:match("at line (%d+)%s*$")
  lnum = statement.line + (reported and (tonumber(reported) - 1) or 0)
  local lines = vim.split(statement.text, "\n", { plain = true })
  local line = lines[lnum - statement.line + 1] or ""
  return lnum, 0, #line
end

-- Statement containing this 0-based row. A blank line uses the statement above it.
function M.at(bufnr, row)
  local previous
  for _, statement in ipairs(split_statements(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false))) do
    if row < statement.line then
      return previous or statement
    end
    if row <= statement.end_line then
      return statement
    end
    previous = statement
  end
  return previous
end

function M.check(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local connection = M.connection(bufnr)
  if not connection then
    return
  end

  local statements = split_statements(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false))
  local diagnostics = {}
  local pending = 0
  local changedtick = vim.api.nvim_buf_get_changedtick(bufnr)

  local function finish()
    pending = pending - 1
    if pending > 0 then
      return
    end
    vim.schedule(function()
      if vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_buf_get_changedtick(bufnr) == changedtick then
        vim.diagnostic.set(namespace, bufnr, diagnostics)
      end
    end)
  end

  for _, statement in ipairs(statements) do
    local keyword = strip_comments(statement.text):match("^%s*(%a+)")
    if keyword and checkable[keyword:lower()] then
      pending = pending + 1
      vim.system({
        "mysql",
        "--host=" .. (connection.host or "127.0.0.1"),
        "--port=" .. (connection.port or "3306"),
        "--user=" .. (connection.user or ""),
        "--database=" .. (connection.dbName or ""),
        "--batch",
        "--silent",
      }, {
        stdin = "EXPLAIN " .. statement.text .. ";",
        env = { MYSQL_PWD = connection.passwd or "" },
        text = true,
      }, function(result)
        local raw = result.code ~= 0 and (result.stderr or ""):match("ERROR [^\n]*")
        if raw then
          local body = raw:gsub("^ERROR %d+ %(%w+%) at line %d+: ", "")
          local lnum, col, end_col = place(statement, body)
          table.insert(diagnostics, {
            lnum = lnum,
            col = col,
            end_col = end_col,
            severity = vim.diagnostic.severity.ERROR,
            source = "mysql",
            message = body,
          })
        end
        finish()
      end)
    end
  end

  if pending == 0 then
    vim.diagnostic.set(namespace, bufnr, {})
  end
end

function M.setup()
  if vim.fn.executable("mysql") ~= 1 then
    return
  end

  local group = vim.api.nvim_create_augroup("SqlExplain", { clear = true })
  vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
    group = group,
    pattern = { "*.sql", "*.mysql" },
    callback = function(args)
      M.check(args.buf)
    end,
  })
end

return M
