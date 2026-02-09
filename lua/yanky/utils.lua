local utils = {}

function utils.is_osc52_active()
  -- If no clipboard set, can't be OSC 52
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
  local clipboard_flags = vim.split(vim.api.nvim_get_option_value("clipboard", {}), ",")
  local selected_register = '"'

  if not utils.is_osc52_active() then
    if vim.tbl_contains(clipboard_flags, "unnamed") then
      selected_register = "*"
    end

    if vim.tbl_contains(clipboard_flags, "unnamedplus") then
      selected_register = "+"
    end
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

function utils.get_register_info(register)
  local ok_contents, regcontents = pcall(vim.fn.getreg, register)
  local ok_type, regtype = pcall(vim.fn.getregtype, register)

  if not ok_contents or not ok_type then
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
