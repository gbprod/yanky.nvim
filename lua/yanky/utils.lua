local utils = {}

function utils.get_default_register()
  local clipboard_tool = vim.fn["provider#clipboard#Executable"]()
  if not clipboard_tool or "" == clipboard_tool then
    return '"'
  end

  local clipboard_flags = vim.split(vim.api.nvim_get_option("clipboard"), ",")

  if vim.tbl_contains(clipboard_flags, "unnamedplus") then
    return "+"
  end

  if vim.tbl_contains(clipboard_flags, "unnamed") then
    return "*"
  end

  return '"'
end

function utils.get_system_register()
  local clipboardFlags = vim.split(vim.api.nvim_get_option("clipboard"), ",")

  if vim.tbl_contains(clipboardFlags, "unnamedplus") then
    return "+"
  end

  return "*"
end

function utils.get_register_info(register)
  return {
    regcontents = vim.fn.getreg(register),
    regtype = vim.fn.getregtype(register),
  }
end

function utils.use_temporary_register(register, register_info, callback)
  local current_register_info = utils.get_register_info(register)
  vim.fn.setreg(register, register_info.regcontents, register_info.regtype)
  callback()
  vim.fn.setreg(register, current_register_info.regcontents, current_register_info.regtype)
end

return utils
