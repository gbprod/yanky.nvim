local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local previewers = require("telescope.previewers")
local actions = require("telescope.actions")
local entry_display = require("telescope.pickers.entry_display")
local conf = require("telescope.config").values
local mapping = require("yanky.telescope.mapping")
local config = require("yanky.config")

local yank_history = {}

function yank_history.get_exports()
  return {
    yank_history = yank_history.yank_history,
  }
end

local regtype_to_text = function(regtype)
  if "v" == regtype then
    return "charwise"
  end

  if "V" == regtype then
    return "linewise"
  end

  return "blockwise"
end

local format_title = function(entry)
  return regtype_to_text(entry.value.regtype)
end

function yank_history.previewer()
  return previewers.new_buffer_previewer({
    dyn_title = function(_, entry)
      return format_title(entry)
    end,
    define_preview = function(self, entry)
      vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, true, vim.split(entry.value.regcontents, "\n"))
      if entry.value.filetype ~= nil then
        vim.bo[self.state.bufnr].filetype = entry.value.filetype
      end
    end,
  })
end

function yank_history.attach_mappings(_, map)
  local mappings = vim.tbl_deep_extend("force", mapping.get_defaults(), config.options.picker.telescope.mappings or {})

  if mappings.default then
    actions.select_default:replace(mappings.default)
  end

  for _, mode in pairs({ "i", "n" }) do
    if mappings[mode] then
      for keys, action in pairs(mappings[mode]) do
        map(mode, keys, action)
      end
    end
  end

  return true
end

function yank_history.gen_from_history(opts)
  local displayer = entry_display.create({
    separator = " ",
    items = {
      { width = #tostring(opts.history_length) },
      { remaining = true },
    },
  })

  local make_display = function(entry)
    local content = entry.content

    return displayer({
      { entry.value.history_index, "TelescopeResultsNumber" },
      content:gsub("\n", "\\n"),
    })
  end

  return function(entry)
    return {
      valid = true,
      value = entry,
      ordinal = entry.regcontents,
      content = entry.regcontents,
      display = make_display,
    }
  end
end

function yank_history.yank_history(opts)
  opts = opts or {}
  local history = {}
  for index, value in pairs(require("yanky.history").all()) do
    value.history_index = index
    history[index] = value
  end

  opts.history_length = #history

  pickers
    .new(opts, {
      prompt_title = "Yank history",
      finder = finders.new_table({
        results = history,
        entry_maker = yank_history.gen_from_history(opts),
      }),
      attach_mappings = yank_history.attach_mappings,
      previewer = yank_history.previewer(),
      sorter = conf.generic_sorter(opts),
    })
    :find()
end

return yank_history
