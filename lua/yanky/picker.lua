local utils = require("yanky.utils")

local picker = {
  actions = {},
}

function picker.setup()
  vim.api.nvim_create_user_command("YankyRingHistory", picker.select_in_history, {})
end

function picker.select_in_history()
  local history = {}
  for index, value in pairs(require("yanky.history").all()) do
    value.history_index = index
    history[index] = value
  end

  local config = require("yanky.config").options.picker.select
  local action = config.action or require("yanky.picker").actions.put("p")

  vim.ui.select(history, {
    prompt = "Ring history",
    format_item = function(item)
      return item.regcontents
    end,
  }, action)
end

function picker.actions.put(type)
  local yanky = require("yanky")

  if not vim.tbl_contains(vim.tbl_values(yanky.type), type) then
    vim.notify("Invalid type " .. type, vim.log.levels.ERROR)
    return
  end

  return function(next_content)
    if nil == next_content then
      return
    end

    utils.use_temporary_register(utils.get_default_register(), next_content, function()
      yanky.put(type, vim.fn.visualmode():match("[vV]"))
    end)
  end
end

return picker
