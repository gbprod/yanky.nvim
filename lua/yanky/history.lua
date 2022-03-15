local config = require("yanky.config")

local history = {
  storage = nil,
  position = nil,
}

history.storage = require("yanky.storage." .. config.options.ring.storage)

function history.push(item)
  if vim.deep_equal(item, history.storage.get(1)) then
    return
  end

  history.storage.push(item)

  if nil ~= history.position then
    history.position = history.position + 1
  end
end

function history.first()
  if history.storage.length() <= 0 then
    return nil
  end

  return history.storage.get(1)
end

function history.skip_first()
  history.position = 1
end

function history.next()
  history.position = history.position ~= nil and history.position + 1 or 1
  if history.position > history.storage.length() then
    return nil
  end

  return history.storage.get(history.position)
end

function history.previous()
  if history.position == nil or history.position == 1 then
    return nil
  end

  history.position = history.position - 1

  return history.storage.get(history.position)
end

function history.reset()
  history.position = nil
end

return history
