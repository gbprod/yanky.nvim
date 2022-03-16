local memory = {
  state = {},
}

function memory.setup(config)
  memory.config = config
end

function memory.push(item)
  table.insert(memory.state, 1, item)

  if #memory.state > memory.config.options.ring.history_length then
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
