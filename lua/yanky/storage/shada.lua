local shada = {}

function shada.setup(config)
  shada.config = config
end

function shada.push(item)
  table.insert(vim.g.YANKY_HISTORY, 1, item)

  if #vim.g.YANKY_HISTORY > shada.config.options.ring.history_length then
    table.remove(vim.g.YANKY_HISTORY)
  end
end

function shada.get(n)
  return vim.g.YANKY_HISTORY[n]
end

function shada.length()
  return #vim.g.YANKY_HISTORY
end

return shada
