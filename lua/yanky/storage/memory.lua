local config = require("yanky.config")

local memory = {
  state = {},
}

function memory.push(item)
  table.insert(memory.state, 1, item)

  if #memory.state > config.options.ring.history_length then
    table.remove(memory.state)
  end
end

function memory.get(n)
  return memory.state[n]
end

function memory.length()
  return #memory.state
end

return memory
