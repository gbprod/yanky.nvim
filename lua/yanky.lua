local utils = require("yanky.utils")
local highlight = require("yanky.highlight")
local system_clipboard = require("yanky.system_clipboard")
local preserve_cursor = require("yanky.preserve_cursor")
local picker = require("yanky.picker")

local yanky = {}

yanky.ring = {
  state = nil,
  is_cycling = false,
  skip_next = false,
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

function yanky.setup(options)
  yanky.config = require("yanky.config")
  yanky.config.setup(options)

  yanky.history = require("yanky.history")
  yanky.history.setup()

  system_clipboard.setup()
  highlight.setup()
  preserve_cursor.setup()
  picker.setup()

  local yanky_augroup = vim.api.nvim_create_augroup("Yanky", { clear = true })
  vim.api.nvim_create_autocmd("TextYankPost", {
    group = yanky_augroup,
    pattern = "*",
    callback = function(_)
      yanky.on_yank()
    end,
  })
  vim.api.nvim_create_autocmd("VimEnter", {
    group = yanky_augroup,
    pattern = "*",
    callback = function(_)
      yanky.init_history()
    end,
  })
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

  local reg_content = vim.fn.getreg(register)
  if nil == reg_content or "" == reg_content then
    vim.notify(string.format('Register "%s" is empty', register), vim.log.levels.WARN)
    return
  end

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

  utils.use_temporary_register(yanky.ring.state.register, next_content, function()
    if new_state.is_visual then -- Can't manage to make visual replacement repeatable
      vim.cmd("silent normal! u")
      do_put(new_state)
    else
      vim.cmd("silent normal! u.")
      highlight.highlight_put(new_state)
    end
  end)

  yanky.ring.is_cycling = true
  yanky.ring.state = new_state
end

function yanky.on_yank()
  -- Only historize first delete in visual mode
  if vim.v.event.visual and vim.v.event.operator == "d" and yanky.ring.is_cycling then
    return
  end
  local entry = utils.get_register_info(vim.v.event.regname)
  entry.filetype = vim.bo.filetype

  yanky.history.push(entry)

  preserve_cursor.on_yank()
end

function yanky.yank()
  preserve_cursor.yank()

  return "y"
end

return yanky
