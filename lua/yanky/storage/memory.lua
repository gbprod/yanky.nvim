local memory = {
  state = {},
}

function memory.setup()
  memory.config = require("yanky.config").options.ring
end

function memory.push(item)
  table.insert(memory.state, 1, item)

  if #memory.state > memory.config.history_length then
    table.remove(memory.state)
  end
end

function memory.get(n)
  return memory.state[n]
end

function memory.length()
  return #memory.state
end

function memory.all()
  return memory.state
end

function memory.clear()
  memory.state = {}
end

function memory.delete(index)
  table.remove(memory.state, index)
end

return memory
