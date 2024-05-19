local config = {}

config.options = {}

local default_values = {
  ring = {
    history_length = 100,
    storage = "shada",
    storage_path = vim.fn.stdpath("data") .. "/databases/yanky.db",
    sync_with_numbered_registers = true,
    ignore_registers = { "_" },
    cancel_event = "update",
    update_register_on_cycle = false,
  },
  system_clipboard = {
    sync_with_ring = true,
    clipboard_register = nil,
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
      use_default_mappings = true,
      mappings = nil,
    },
  },
  textobj = {
    enabled = false,
  },
}

function config.setup(options)
  config.options = vim.tbl_deep_extend("force", default_values, options or {})
end

return config
