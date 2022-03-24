local shada = {}

function shada.setup(config)
  shada.config = config
  if nil == vim.g.YANKY_HISTORY then
    vim.g.YANKY_HISTORY = {}
  end
end

function shada.push(item)
  local copy = vim.deepcopy(vim.g.YANKY_HISTORY)
  table.insert(copy, 1, item)

  if #copy > shada.config.options.ring.history_length then
    table.remove(copy)
  end

  vim.g.YANKY_HISTORY = copy
end

function shada.get(n)
  return vim.g.YANKY_HISTORY[n]
end

function shada.length()
  return #vim.g.YANKY_HISTORY
end

return shada
