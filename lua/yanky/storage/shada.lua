local shada = {}

function shada.setup()
  shada.config = require("yanky.config").options.ring
end

function shada.push(item)
  local copy = vim.deepcopy(vim.g.YANKY_HISTORY)
  table.insert(copy, 1, item)

  if #copy > shada.config.history_length then
    table.remove(copy)
  end

  vim.g.YANKY_HISTORY = copy
end

function shada.get(n)
  if nil == vim.g.YANKY_HISTORY then
    vim.g.YANKY_HISTORY = {}
  end

  return vim.g.YANKY_HISTORY[n]
end

function shada.length()
  if nil == vim.g.YANKY_HISTORY then
    vim.g.YANKY_HISTORY = {}
  end

  return #vim.g.YANKY_HISTORY
end

function shada.all()
  if nil == vim.g.YANKY_HISTORY then
    vim.g.YANKY_HISTORY = {}
  end

  return vim.g.YANKY_HISTORY
end

function shada.clear()
  vim.g.YANKY_HISTORY = {}
end

function shada.delete(index)
  local copy = vim.deepcopy(vim.g.YANKY_HISTORY)
  table.remove(copy, index)

  vim.g.YANKY_HISTORY = copy
end

return shada
