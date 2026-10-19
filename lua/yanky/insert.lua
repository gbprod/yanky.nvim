local utils = require("yanky.utils")
local highlight = require("yanky.highlight")

local insert = {}

insert.state = nil

local native_keys = {
  ["="] = "",
  [vim.api.nvim_replace_termcodes("<C-r>", true, false, true)] = "",
  [vim.api.nvim_replace_termcodes("<C-o>", true, false, true)] = "",
  [vim.api.nvim_replace_termcodes("<C-p>", true, false, true)] = "",
}

local function to_lines(entry)
  local lines = vim.split(entry.regcontents, "\n", { plain = true })
  if entry.regtype == "V" and lines[#lines] ~= "" then
    table.insert(lines, "")
  end

  return lines
end

local function is_last_action_put()
  local state = insert.state
  if nil == state then
    return false
  end

  local cursor = vim.api.nvim_win_get_cursor(0)

  return vim.api.nvim_get_current_buf() == state.bufnr
    and vim.api.nvim_buf_get_changedtick(state.bufnr) == state.changedtick
    and cursor[1] - 1 == state.end_row
    and cursor[2] == state.end_col
end

function insert.clear()
  insert.state = nil
  pcall(vim.api.nvim_clear_autocmds, { group = "YankyInsertRingClear" })
end

local function attach_cancel()
  local group = vim.api.nvim_create_augroup("YankyInsertRingClear", { clear = true })

  vim.api.nvim_create_autocmd("CursorMovedI", {
    group = group,
    buffer = insert.state.bufnr,
    callback = function()
      if not is_last_action_put() then
        insert.clear()
      end
    end,
  })

  vim.api.nvim_create_autocmd("InsertLeave", {
    group = group,
    buffer = insert.state.bufnr,
    callback = insert.clear,
  })
end

local function set_text(start_row, start_col, end_row, end_col, entry)
  local lines = to_lines(entry)
  vim.api.nvim_buf_set_text(0, start_row, start_col, end_row, end_col, lines)

  local new_end_row = start_row + #lines - 1
  local new_end_col = #lines == 1 and start_col + #lines[1] or #lines[#lines]
  vim.api.nvim_win_set_cursor(0, { new_end_row + 1, new_end_col })

  insert.state = {
    bufnr = vim.api.nvim_get_current_buf(),
    register = insert.state and insert.state.register,
    start_row = start_row,
    start_col = start_col,
    end_row = new_end_row,
    end_col = new_end_col,
    changedtick = vim.api.nvim_buf_get_changedtick(0),
    is_cycling = insert.state and insert.state.is_cycling or false,
  }

  highlight.highlight_insert_put(insert.state)
  attach_cancel()
end

function insert.put(register)
  if nil == register then
    local ok, char = pcall(vim.fn.getcharstr)
    if not ok or char == vim.api.nvim_replace_termcodes("<Esc>", true, false, true) then
      return
    end

    if nil ~= native_keys[char] then
      insert.clear()
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-r>", true, false, true) .. char, "in", false)
      return
    end

    register = char
  end

  -- Like native `<C-r>_`, black hole register inserts nothing
  if register == "_" then
    insert.clear()
    return
  end

  register = register ~= '"' and utils.get_register(register) or utils.get_default_register()

  local entry = utils.get_register_info(register)
  if nil == entry or "" == entry.regcontents then
    vim.notify(string.format('Register "%s" is empty', register), vim.log.levels.WARN)
    return
  end

  local cursor = vim.api.nvim_win_get_cursor(0)
  insert.state = { register = register, is_cycling = false }
  set_text(cursor[1] - 1, cursor[2], cursor[1] - 1, cursor[2], entry)
end

function insert.cycle(direction)
  if not is_last_action_put() then
    insert.clear()
    vim.notify("Your last action was not put, ignoring cycle", vim.log.levels.INFO)
    return
  end

  local yanky = require("yanky")
  local history = yanky.history
  local state = insert.state

  if not state.is_cycling then
    history.reset()

    local reg = utils.get_register_info(state.register)
    local first = history.first()
    if nil ~= reg and nil ~= first and reg.regcontents == first.regcontents and reg.regtype == first.regtype then
      history.skip()
    end
  end

  local next_content
  if direction == yanky.direction.BACKWARD then
    next_content = history.previous()
    if nil == next_content then
      vim.notify("Reached first item", vim.log.levels.INFO)
      return
    end
  else
    next_content = history.next()
    if nil == next_content then
      vim.notify("Reached oldest item", vim.log.levels.INFO)
      return
    end
  end

  state.is_cycling = true
  set_text(state.start_row, state.start_col, state.end_row, state.end_col, next_content)

  if yanky.config.options.ring.update_register_on_cycle then
    vim.fn.setreg(state.register, next_content.regcontents, next_content.regtype)
  end
end

return insert
