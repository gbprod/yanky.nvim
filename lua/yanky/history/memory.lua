local config = require("yanky.config")
local utils = require("yanky.utils")

local history = {}

function history.clear()
  local reg = utils.get_default_register()
  history.state = {
    {
      regcontents = vim.fn.getreg(reg),
      regtype = vim.fn.getregtype(reg),
    },
  }
end

function history.push(item)
  if vim.deep_equal(item, history.state[1]) then
    return
  end

  local new_state = { item }
  local length = vim.fn.min({ vim.tbl_count(history.state), config.options.ring.history_length })
  for _, value in pairs(vim.fn.range(1, length)) do
    table.insert(new_state, history.state[value])
  end

  history.state = new_state
end

function history.get(n)
  return history.state[n]
end

function history.length()
  return #history.state
end

history.clear()

return history
