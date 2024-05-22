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
    local yanky_clipboard_augroup = vim.api.nvim_create_augroup("YankySyncClipboard", { clear = true })
    local fetching = false
    vim.api.nvim_create_autocmd("FocusGained", {
      group = yanky_clipboard_augroup,
      pattern = "*",
      callback = function(_)
        if fetching then
          return
        end
        fetching = true
        local ok, err = pcall(system_clipboard.on_focus_gained)
        vim.schedule(function()
          fetching = false
        end)
        if not ok then
          error(err)
        end
      end,
    })
    vim.api.nvim_create_autocmd("FocusLost", {
      group = yanky_clipboard_augroup,
      pattern = "*",
      callback = function(_)
        if fetching then
          return
        end
        system_clipboard.on_focus_lost()
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
