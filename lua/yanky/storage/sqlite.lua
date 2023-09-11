local sqlite = {
  db = nil,
}

function sqlite.setup()
  sqlite.config = require("yanky.config").options.ring

  local has_sqlite, connection = pcall(require, "sqlite")
  if not has_sqlite then
    if type(connection) ~= "string" then
      vim.notify("Couldn't find sqlite.lua.", vim.log.levels.ERROR, {})
    else
      vim.notify("Found sqlite.lua: but got the following error: " .. connection)
    end

    return false
  end

  vim.fn.mkdir(string.match(sqlite.config.storage_path, "(.*[/\\])"), "p")

  sqlite.db = connection:open(sqlite.config.storage_path)
  if not sqlite.db then
    vim.notify("Error in opening DB", vim.log.levels.ERROR)
    return
  end

  if not sqlite.db:exists("history") then
    sqlite.db:create("history", {
      id = { "integer", "primary", "key", "autoincrement" },
      regcontents = "text",
      regtype = "text",
      filetype = "text",
    })
  end

  sqlite.db:close()
end

function sqlite.push(item)
  sqlite.db:with_open(function()
    sqlite.db:eval(
      "INSERT INTO history (filetype, regcontents, regtype) VALUES (:filetype, :regcontents, :regtype)",
      item
    )

    sqlite.db:eval(
      string.format(
        "DELETE FROM history WHERE id NOT IN (SELECT id FROM history ORDER BY id DESC LIMIT %s)",
        sqlite.config.history_length
      )
    )
  end)
end

function sqlite.get(index)
  return sqlite.db:with_open(function()
    return sqlite.db:select("history", { order_by = { desc = "id" }, limit = { 1, index - 1 } })[1]
  end)
end

function sqlite.length()
  return sqlite.db:with_open(function()
    return sqlite.db:tbl("history"):count()
  end)
end

function sqlite.all()
  return sqlite.db:with_open(function()
    return sqlite.db:select("history", { order_by = { desc = "id" } })
  end)
end

function sqlite.clear()
  return sqlite.db:with_open(function()
    return sqlite.db:delete("history")
  end)
end

function sqlite.delete(index)
  return sqlite.db:with_open(function()
    return sqlite.db:eval(
      string.format(
        "DELETE FROM history WHERE id IN (SELECT id FROM history ORDER BY id DESC LIMIT 1 OFFSET %s)",
        index - 1
      )
    )
  end)
end

return sqlite
