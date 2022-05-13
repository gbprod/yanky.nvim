local history = {
  storage = nil,
  position = 1,
  config = nil,
}

function history.setup()
  history.config = require("yanky.config").options.ring
  history.storage = require("yanky.storage." .. history.config.storage)
  history.storage.setup()
end

function history.push(item)
  if vim.deep_equal(item, history.storage.get(1)) then
    return
  end

  history.storage.push(item)

  history.sync_with_numbered_registers()
end

function history.sync_with_numbered_registers()
  if history.config.sync_with_numbered_registers then
    for i = 1, math.min(history.storage.length(), 9) do
      local reg = history.storage.get(i)
      vim.fn.setreg(i, reg.regcontents, reg.regtype)
    end
  end
end

function history.first()
  if history.storage.length() <= 0 then
    return nil
  end

  return history.storage.get(1)
end

function history.skip()
  history.position = history.position + 1
end

function history.next()
  local new_position = history.position + 1
  if new_position > history.storage.length() then
    return nil
  end

  history.position = new_position

  return history.storage.get(history.position)
end

function history.previous()
  if history.position == 1 then
    return nil
  end

  history.position = history.position - 1

  return history.storage.get(history.position)
end

function history.reset()
  history.position = 1
end

function history.all()
  return history.storage.all()
end

function history.clear()
  history.storage.clear()
  history.position = 1
end

function history.delete(index)
  history.storage.delete(index)
end

return history
