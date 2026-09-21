local history = {
  storage = nil,
  position = 1,
  config = nil,
}

function history.setup()
  history.config = require("yanky.config").options.ring
  history.storage = require("yanky.storage." .. history.config.storage)
  if false == history.storage.setup() then
    history.storage = require("yanky.storage.memory")
  end
end

-- Deletes and changes shift vim numbered registers before yanky sees them,
-- yanks and entries coming from outside of a buffer don't.
local function has_shifted_numbered_registers(context)
  return context.source == "yank" and (context.event.operator == "d" or context.event.operator == "c")
end

-- Restore numbered registers from the history after a shift that yanky did not
-- record, including the registers that are no longer backed by an history entry.
local function restore_numbered_registers()
  if not history.config.sync_with_numbered_registers then
    return
  end

  history.sync_with_numbered_registers()

  for i = history.storage.length() + 1, 9 do
    vim.fn.setreg(tostring(i), "", "v")
  end
end

function history.push(item, context)
  if item == nil then
    -- `utils.get_register_info` returns nil when the register can't be read
    -- (e.g. a clipboard provider error), so there is nothing to push.
    return
  end

  context = context or { source = "unknown" }

  if history.config.filter ~= nil and not history.config.filter(item, context) then
    if has_shifted_numbered_registers(context) then
      restore_numbered_registers()
    end

    return
  end

  local prev = history.storage.get(1)
  if prev ~= nil and prev.regcontents == item.regcontents and prev.regtype == item.regtype then
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
  history.position = 0
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
