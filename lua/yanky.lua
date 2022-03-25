local utils = require("yanky.utils")
local highlight = require("yanky.highlight")
local system_clipboard = require("yanky.system_clipboard")

local yanky = {}

yanky.ring = {
  state = nil,
  is_cycling = false,
  skip_next = false,
}

yanky.preserve_position = {
  cusor_position = nil,
  win_state = nil,
}

yanky.direction = {
  FORWARD = 1,
  BACKWARD = -1,
}

yanky.type = {
  PUT_BEFORE = "P",
  PUT_AFTER = "p",
  GPUT_BEFORE = "gP",
  GPUT_AFTER = "gp",
}

yanky.storage = {
  SHADA = "shada",
  MEMORY = "memory",
}

function yanky.setup(options)
  yanky.config = require("yanky.config")
  yanky.config.setup(options)

  yanky.history = require("yanky.history")
  yanky.history.setup(yanky.config)

  if not vim.tbl_contains(vim.tbl_values(yanky.storage), yanky.config.options.ring.storage) then
    vim.notify("Invalid storage " .. yanky.config.options.ring.storage, vim.log.levels.ERROR)
    return
  end

  system_clipboard.setup(yanky.history, yanky.config)
  highlight.setup(yanky.config)

  vim.cmd([[
  augroup Yanky
    au!
    autocmd TextYankPost * lua require('yanky').on_yank()
    autocmd VimEnter * lua require('yanky').init_history()
  augroup END
  ]])
end

function yanky.init_history()
  yanky.history.push(utils.get_register_info(utils.get_default_register()))
  yanky.history.sync_with_numbered_registers()
end

local function do_put(state)
  if state.is_visual then
    vim.cmd([[execute "normal! \<esc>"]])
  end

  vim.cmd(
    string.format('silent normal! %s"%s%s%s', state.is_visual and "gv" or "", state.register, state.count, state.type)
  )

  highlight.highlight_put(state)
end

function yanky.put(type, is_visual)
  if not vim.tbl_contains(vim.tbl_values(yanky.type), type) then
    vim.notify("Invalid type " .. type, vim.log.levels.ERROR)
    return
  end

  yanky.ring.state = nil
  yanky.ring.is_cycling = false
  yanky.ring.skip_next = false
  yanky.init_ring(type, vim.v.register, vim.v.count, is_visual, do_put)
end

function yanky.init_ring(type, register, count, is_visual, callback)
  register = register ~= '"' and register or utils.get_default_register()
  local new_state = {
    type = type,
    register = register,
    count = count > 0 and count or 1,
    is_visual = is_visual,
  }

  if nil ~= callback then
    callback(new_state)
  end

  yanky.ring.state = new_state
  yanky.ring.is_cycling = false
  yanky.ring.skip_next = false

  vim.api.nvim_buf_attach(0, false, {
    on_lines = function()
      yanky.ring.state = nil
      yanky.ring.is_cycling = false

      return true
    end,
  })
end

function yanky.cycle(direction)
  if nil == yanky.ring.state then
    vim.notify("Your last action was not put, ignoring cycle", vim.log.levels.INFO)
    return
  end

  direction = direction or yanky.direction.FORWARD

  if not vim.tbl_contains(vim.tbl_values(yanky.direction), direction) then
    vim.notify("Invalid direction for cycle", vim.log.levels.ERROR)
    return
  end

  if not yanky.ring.is_cycling then
    yanky.history.reset()
  end

  if yanky.ring.skip_next then
    yanky.history.skip()
    yanky.ring.skip_next = false
  end

  local current_register_info = utils.get_register_info(yanky.ring.state.register)

  local new_state = yanky.ring.state
  local next_content

  if direction == yanky.direction.FORWARD then
    next_content = yanky.history.next()
    if nil == next_content then
      vim.notify("Reached oldest item", vim.log.levels.INFO)
      return
    end
  else
    next_content = yanky.history.previous()
    if nil == next_content then
      vim.notify("Reached first item", vim.log.levels.INFO)
      return
    end
  end

  vim.fn.setreg(new_state.register, next_content.regcontents, next_content.regtype)

  if new_state.is_visual then -- Can't manage to make visual replacement repeatable
    vim.cmd("silent normal! u")
    do_put(new_state)
  else
    vim.cmd("silent normal! u.")
    highlight.highlight_put(new_state)
  end

  vim.fn.setreg(new_state.register, current_register_info.regcontents, current_register_info.regtype)

  yanky.ring.is_cycling = true
  yanky.ring.state = new_state
end

function yanky.on_yank()
  -- Only historize first delete in visual mode
  if vim.v.event.visual and vim.v.event.operator == "d" and yanky.ring.is_cycling then
    return
  end

  yanky.history.push(utils.get_register_info(vim.v.event.regname))

  if nil ~= yanky.preserve_position.cusor_position then
    vim.fn.setpos(".", yanky.preserve_position.cusor_position)
    vim.fn.winrestview(yanky.preserve_position.win_state)

    yanky.preserve_position.cusor_position = nil
    yanky.preserve_position.win_state = nil
  end
end

function yanky.yank()
  yanky.preserve_position.cusor_position = vim.fn.getpos(".")
  yanky.preserve_position.win_state = vim.fn.winsaveview()

  vim.api.nvim_buf_attach(0, false, {
    on_lines = function()
      yanky.preserve_position.cusor_position = nil
      yanky.preserve_position.win_state = nil

      return true
    end,
  })

  return "y"
end

return yanky
