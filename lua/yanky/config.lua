local config = {}

config.options = {}

local default_values = {
  ring = {
    history_length = 100,
    storage = "shada",
    sync_with_numbered_registers = true,
    ignore_registers = { "_" },
    cancel_event = "update",
  },
  system_clipboard = {
    sync_with_ring = true,
  },
  highlight = {
    on_put = true,
    on_yank = true,
    timer = 500,
  },
  preserve_cursor_position = {
    enabled = true,
  },
  picker = {
    select = {
      action = nil,
    },
    telescope = {
      mappings = nil,
    },
  },
}

function config.setup(options)
  config.options = vim.tbl_deep_extend("force", default_values, options or {})
end

return config
