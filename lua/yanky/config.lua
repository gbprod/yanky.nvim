local config = {}

config.options = {}

local function with_defaults(options)
  return {
    ring = {
      history_length = options.ring and options.ring.history_length or 100,
      storage = options.ring and options.ring.storage or "shada",
      sync_with_numbered_registers = options.ring and options.ring.sync_with_numbered_registers or true,
    },
    system_clipboard = {
      sync_with_ring = options.system_clipboard and options.system_clipboard.sync_with_ring or true,
    },
    highlight = {
      on_put = options.highlight and options.highlight.on_put or true,
      on_yank = options.highlight and options.highlight.on_yank or true,
      timer = options.highlight and options.highlight.timer or 500,
    },
    preserve_cursor_position = {
      enabled = options.preserve_cursor_position and options.preserve_cursor_position.enabled or true,
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
end

function config.setup(options)
  config.options = with_defaults(options or {})
end

return config
