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
