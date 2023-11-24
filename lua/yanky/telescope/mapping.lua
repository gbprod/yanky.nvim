local picker = require("yanky.picker")
local utils = require("yanky.utils")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local mapping = {
  state = { is_visual = false },
}

function mapping.put(type)
  return function(prompt_bufnr)
    if vim.api.nvim_buf_is_valid(prompt_bufnr) then
      actions.close(prompt_bufnr)
    end
    local selection = action_state.get_selected_entry()

    -- fix cursor position since
    -- https://github.com/nvim-telescope/telescope.nvim/commit/3eb90430b61b78b707e8ffe0cfe49138daaddbcc
    local cursor_pos = nil
    if vim.api.nvim_get_mode().mode == "i" then
      cursor_pos = vim.api.nvim_win_get_cursor(0)
    end

    vim.schedule(function()
      if nil ~= cursor_pos then
        vim.api.nvim_win_set_cursor(0, { cursor_pos[1], math.max(cursor_pos[2] - 1, 0) })
      end
      picker.actions.put(type, mapping.state.is_visual)(selection.value)
    end)
  end
end

function mapping.special_put(name)
  return function(prompt_bufnr)
    if vim.api.nvim_buf_is_valid(prompt_bufnr) then
      actions.close(prompt_bufnr)
    end
    local selection = action_state.get_selected_entry()

    -- fix cursor position since
    -- https://github.com/nvim-telescope/telescope.nvim/commit/3eb90430b61b78b707e8ffe0cfe49138daaddbcc
    local cursor_pos = nil
    if vim.api.nvim_get_mode().mode == "i" then
      cursor_pos = vim.api.nvim_win_get_cursor(0)
    end

    vim.schedule(function()
      if nil ~= cursor_pos then
        vim.api.nvim_win_set_cursor(0, { cursor_pos[1], math.max(cursor_pos[2] - 1, 0) })
      end
      picker.actions.special_put(name, mapping.state.is_visual)(selection.value)
    end)
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
    if vim.api.nvim_buf_is_valid(prompt_bufnr) then
      actions.close(prompt_bufnr)
    end
    local selection = action_state.get_selected_entry()

    vim.schedule(function()
      picker.actions.set_register(register)(selection.value)
    end)
  end
end

function mapping.put_and_set_register(type, register)
  return function(prompt_bufnr)
    mapping.put(type)(prompt_bufnr)
    mapping.set_register(register)(prompt_bufnr)
  end
end

function mapping.get_defaults()
  return {
    default = mapping.put("p"),
    i = {
      ["<c-g>"] = mapping.put("p"),
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
