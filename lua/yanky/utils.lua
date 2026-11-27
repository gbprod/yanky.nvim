local utils = {}

local blockwise_mode = vim.api.nvim_replace_termcodes("<C-v>", true, false, true)

function utils.is_visual_mode()
  local mode = vim.fn.mode()

  return mode == "v" or mode == "V" or mode == blockwise_mode
end

function utils.is_osc52_active()
  if not vim.g.clipboard then
    return false
  end

  -- Per the docs, OSC 52 should be set up with a name field in the table
  if vim.g.clipboard.name == "OSC 52" then
    return true
  end

  return false
end

function utils.get_default_register()
  if utils.is_osc52_active() then
    return '"'
  end

  local clipboard_flags = vim.split(vim.api.nvim_get_option_value("clipboard", {}), ",")
  local selected_register = '"'

  if vim.tbl_contains(clipboard_flags, "unnamed") then
    selected_register = "*"
  end

  if vim.tbl_contains(clipboard_flags, "unnamedplus") then
    selected_register = "+"
  end

  if selected_register ~= '"' then
    local clipboard_tool = vim.fn["provider#clipboard#Executable"]()
    if not clipboard_tool or "" == clipboard_tool then
      return '"'
    end
  end

  return selected_register
end

function utils.get_system_register()
  local clipboard_flags = vim.split(vim.api.nvim_get_option_value("clipboard", {}), ",")

  if vim.tbl_contains(clipboard_flags, "unnamedplus") then
    return "+"
  end
  return "*"
end

function utils.get_register(register)
  register = register or vim.v.register
  if utils.is_osc52_active() and (register == "+" or register == "*") then
    return '"'
  end
  return register
end

local register_info_id = 0

local function silent_get_expr(expr_name, register)
  register_info_id = register_info_id + 1
  local var_name = ("_yanky_register_info_%d"):format(register_info_id)
  local ok = pcall(vim.cmd, ("silent! let g:%s = %s(%s)"):format(var_name, expr_name, vim.fn.string(register)))
  local value = ok and vim.g[var_name] or nil
  vim.g[var_name] = nil
  return value
end

function utils.get_register_info(register)
  local regcontents = silent_get_expr("getreg", register)
  local regtype = silent_get_expr("getregtype", register)

  if regcontents == nil or regtype == nil then
    return nil
  end

  return {
    regcontents = regcontents,
    regtype = regtype,
  }
end

function utils.use_temporary_register(register, register_info, callback)
  local current_register_info = utils.get_register_info(register)
  vim.fn.setreg(register, register_info.regcontents, register_info.regtype)
  callback()
  vim.fn.setreg(register, current_register_info.regcontents, current_register_info.regtype)
end

return utils
