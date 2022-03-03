local config = require("yanky.config")
local utils = require("yanky.utils")

local history = {}

function history.clear()
  local reg = utils.get_default_register()

  vim.g.YANKY_HISTORY = {
    {
      regcontents = vim.fn.getreg(reg),
      regtype = vim.fn.getregtype(reg),
    },
  }
end

function history.push(item)
  if vim.deep_equal(item, vim.g.YANKY_HISTORY[1]) then
    return
  end

  local new_state = { item }
  local length = vim.fn.min({ vim.tbl_count(vim.g.YANKY_HISTORY), config.options.ring.history_length })
  for _, value in pairs(vim.fn.range(1, length)) do
    table.insert(new_state, vim.g.YANKY_HISTORY[value])
  end

  vim.g.YANKY_HISTORY = new_state
end

function history.get(n)
  return vim.g.YANKY_HISTORY[n]
end

function history.length()
  return #vim.g.YANKY_HISTORY
end

if nil == vim.g.YANKY_HISTORY then
  history.clear()
end

return history
