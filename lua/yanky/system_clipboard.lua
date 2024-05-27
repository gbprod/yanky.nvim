local utils = require("yanky.utils")

local system_clipboard = {
  state = {
    reg_info_on_focus_lost = nil,
  },
}

function system_clipboard.setup()
  system_clipboard.config = require("yanky.config").options.system_clipboard
  system_clipboard.config.clipboard_register = system_clipboard.config.clipboard_register or utils.get_system_register()
  system_clipboard.history = require("yanky.history")

  if system_clipboard.config.sync_with_ring then
    vim.api.nvim_create_autocmd({ "FocusGained", "FocusLost" }, {
      group = vim.api.nvim_create_augroup("YankySyncClipboard", { clear = true }),
      callback = function(ev)
        -- don't execute focus autocmds while fetching the clipboard,
        -- since clipboard tools can steal focus
        if utils.fetching then
          return
        elseif ev.event == "FocusLost" then
          system_clipboard.on_focus_lost()
        elseif ev.event == "FocusGained" then
          system_clipboard.on_focus_gained()
        end
      end,
    })
  end
end

function system_clipboard.on_focus_lost()
  system_clipboard.state.reg_info_on_focus_lost = utils.get_register_info(system_clipboard.config.clipboard_register)
end

function system_clipboard.on_focus_gained()
  local new_reg_info = utils.get_register_info(system_clipboard.config.clipboard_register)

  if
    system_clipboard.state.reg_info_on_focus_lost ~= nil
    and not vim.deep_equal(system_clipboard.state.reg_info_on_focus_lost, new_reg_info)
  then
    system_clipboard.history.push(new_reg_info)
  end

  system_clipboard.state.reg_info_on_focus_lost = nil
end

return system_clipboard
