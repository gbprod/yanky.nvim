local config = require("yanky.config")
local history = require("yanky.history")
local utils = require("yanky.utils")
local highlight = require("yanky.highlight")

local yanky = {}

yanky.state = nil

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
  config.setup(options)
  history.load()
  highlight.setup()

  vim.cmd([[
  augroup Yanky
    au! TextYankPost * lua require'yanky'.on_yank()
  augroup END
  ]])
end

local function do_put(state)
  vim.cmd(
    string.format('silent normal! %s"%s%s%s', state.is_visual and "gv" or "", state.register, state.count, state.type)
  )

  highlight.highlight_put(state)
end

function yanky.put(type, is_visual)
  if not vim.tbl_contains(vim.tbl_values(yanky.type), type) then
    vim.notify("Invalid type" .. type, vim.log.levels.ERROR)
    return
  end

  local state = {
    type = type,
    register = vim.v.register ~= '"' and vim.v.register or utils.get_default_register(),
    history_pos = is_visual and 2 or 1,
    count = vim.v.count > 0 and vim.v.count or 1,
    is_visual = is_visual,
  }

  if is_visual then
    vim.cmd([[execute "normal! \<esc>"]])
  end

  do_put(state)

  yanky.state = state

  vim.api.nvim_buf_attach(0, false, {
    on_lines = function()
      yanky.state = nil
      return true
    end,
  })
end

function yanky.cycle(direction)
  if nil == yanky.state then
    vim.notify("Your last action was not put, ignoring cycle", vim.log.levels.INFO)
    return
  end

  direction = direction or yanky.direction.FORWARD
  if not vim.tbl_contains(vim.tbl_values(yanky.direction), direction) then
    vim.notify("Invalid direction for cycle", vim.log.levels.ERROR)
    return
  end

  local current_register_info = {
    regcontents = vim.fn.getreg(yanky.state.register),
    regtype = vim.fn.getregtype(yanky.state.register),
  }

  local new_state = yanky.state

  new_state.history_pos = new_state.history_pos or 1

  if direction == yanky.direction.FORWARD then
    if new_state.history_pos >= history.length() then
      vim.notify("Reached oldest item", vim.log.levels.INFO)
      return
    end

    new_state.history_pos = new_state.history_pos + 1
  else
    if new_state.history_pos <= 1 then
      vim.notify("Reached first item", vim.log.levels.INFO)
      return
    end
    new_state.history_pos = new_state.history_pos - 1
  end

  local item = history.get(new_state.history_pos)

  vim.fn.setreg(new_state.register, item.regcontents, item.regtype)

  vim.cmd("silent undo")
  do_put(new_state)

  vim.fn.setreg(new_state.register, current_register_info.regcontents, current_register_info.regtype)

  yanky.state = new_state
end

function yanky.on_yank()
  history.push({
    regcontents = vim.fn.getreg(vim.v.event.regname),
    regtype = vim.fn.getregtype(vim.v.event.regname),
  })
end

return yanky
