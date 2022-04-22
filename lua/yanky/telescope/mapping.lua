local picker = require("yanky.picker")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local mapping = {}

function mapping.put(type)
  return function(prompt_bufnr)
    actions.close(prompt_bufnr)
    local selection = action_state.get_selected_entry()
    picker.actions.put(type)(selection.value)
  end
end

function mapping.get_defaults()
  return {
    default = mapping.put("p"),
    i = {
      ["<c-p>"] = mapping.put("p"),
      ["<c-k>"] = mapping.put("P"),
    },
    n = {
      ["p"] = mapping.put("p"),
      ["P"] = mapping.put("P"),
    },
  }
end

return mapping
