local wrappers = {}

function wrappers.linewise(next)
  return function(state, callback)
    local body = vim.fn.getreg(state.register)
    local type = vim.fn.getregtype(state.register)

    vim.fn.setreg(state.register, body, "l")

    if nil == next then
      callback(state)
    else
      next(state, callback)
    end

    vim.fn.setreg(state.register, body, type)
  end
end

function wrappers.charwise(next)
  return function(state, callback)
    local body = vim.fn.getreg(state.register)
    local type = vim.fn.getregtype(state.register)

    local reformated_body = body:gsub("\n$", "")
    vim.fn.setreg(state.register, reformated_body, "c")

    if nil == next then
      callback(state)
    else
      next(state, callback)
    end

    vim.fn.setreg(state.register, body, type)
  end
end

function wrappers.blockwise(next)
  return function(state, callback)
    local body = vim.fn.getreg(state.register)
    local type = vim.fn.getregtype(state.register)

    vim.fn.setreg(state.register, body, "b")

    if nil == next then
      callback(state)
    else
      next(state, callback)
    end

    vim.fn.setreg(state.register, body, type)
  end
end

function wrappers.trim_and_join_lines(next)
  return function(state, callback)
    local body = vim.fn.getreg(state.register)

    local reformated_body = body:gsub("%s*\r?\n%s*", " "):gsub("^%s*", ""):gsub("%s*$", "")
    vim.fn.setreg(state.register, reformated_body, vim.fn.getregtype(state.register))

    if nil == next then
      callback(state)
    else
      next(state, callback)
    end

    vim.fn.setreg(state.register, body, vim.fn.getregtype(state.register))
  end
end

function wrappers.change(change, next)
  return function(state, callback)
    if nil == next then
      callback(state)
    else
      next(state, callback)
    end

    vim.cmd(string.format("normal! %s']", change))
  end
end

return wrappers
