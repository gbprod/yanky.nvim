local utils = require("yanky.utils")

local system_clipboard = {
  state = {
    reg_info_on_focus_lost = nil,
  },
}

function system_clipboard.setup()
  system_clipboard.config = require("yanky.config").options.system_clipboard
  system_clipboard.history = require("yanky.history")

  if system_clipboard.config.sync_with_ring then
    vim.cmd([[
      augroup YankySyncClipboard
        au!
        autocmd FocusGained * lua require('yanky.system_clipboard').on_focus_gained()
        autocmd FocusLost * lua require('yanky.system_clipboard').on_focus_lost()
      augroup END
    ]])
  end
end

function system_clipboard.on_focus_lost()
  system_clipboard.state.reg_info_on_focus_lost = utils.get_register_info(utils.get_system_register())
end

function system_clipboard.on_focus_gained()
  local new_reg_info = utils.get_register_info(utils.get_system_register())

  if
    system_clipboard.state.reg_info_on_focus_lost ~= nil
    and not vim.deep_equal(system_clipboard.state.reg_info_on_focus_lost, new_reg_info)
  then
    system_clipboard.history.push(new_reg_info)
  end

  system_clipboard.state.reg_info_on_focus_lost = nil
end

return system_clipboard
