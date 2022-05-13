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

function mapping.delete()
  return function(prompt_bufnr)
    local current_picker = action_state.get_current_picker(prompt_bufnr)
    current_picker:delete_selection(function(selection)
      picker.actions.delete()(selection.value)
    end)
  end
end

function mapping.get_defaults()
  return {
    default = mapping.put("p"),
    i = {
      ["<c-p>"] = mapping.put("p"),
      ["<c-k>"] = mapping.put("P"),
      ["<c-x>"] = mapping.delete(),
    },
    n = {
      p = mapping.put("p"),
      P = mapping.put("P"),
      d = mapping.delete(),
    },
  }
end

return mapping
