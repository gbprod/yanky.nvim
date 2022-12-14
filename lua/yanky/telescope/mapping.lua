local picker = require("yanky.picker")
local utils = require("yanky.utils")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local mapping = {}

function mapping.put(type)
  return function(prompt_bufnr)
    actions.close(prompt_bufnr)
    local selection = action_state.get_selected_entry()

    -- fix cursor position since
    -- https://github.com/nvim-telescope/telescope.nvim/commit/3eb90430b61b78b707e8ffe0cfe49138daaddbcc
    if vim.api.nvim_get_mode().mode == "i" then
      local cursor_pos = vim.api.nvim_win_get_cursor(0)
      vim.api.nvim_win_set_cursor(0, { cursor_pos[1], math.max(cursor_pos[2] - 1, 0) })
    end
    picker.actions.put(type)(selection.value)
  end
end

function mapping.special_put(name)
  return function(prompt_bufnr)
    actions.close(prompt_bufnr)
    local selection = action_state.get_selected_entry()

    -- fix cursor position since
    -- https://github.com/nvim-telescope/telescope.nvim/commit/3eb90430b61b78b707e8ffe0cfe49138daaddbcc
    if vim.api.nvim_get_mode().mode == "i" then
      local cursor_pos = vim.api.nvim_win_get_cursor(0)
      vim.api.nvim_win_set_cursor(0, { cursor_pos[1], math.max(cursor_pos[2] - 1, 0) })
    end
    picker.actions.special_put(name)(selection.value)
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

function mapping.set_register(register)
  return function(prompt_bufnr)
    actions.close(prompt_bufnr)
    local selection = action_state.get_selected_entry()
    picker.actions.set_register(register)(selection.value)
  end
end

function mapping.get_defaults()
  return {
    default = mapping.put("p"),
    i = {
      ["<c-p>"] = mapping.put("p"),
      ["<c-k>"] = mapping.put("P"),
      ["<c-x>"] = mapping.delete(),
      ["<c-r>"] = mapping.set_register(utils.get_default_register()),
    },
    n = {
      p = mapping.put("p"),
      P = mapping.put("P"),
      d = mapping.delete(),
      r = mapping.set_register(utils.get_default_register()),
    },
  }
end

return mapping
