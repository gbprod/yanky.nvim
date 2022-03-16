local config = {}

config.options = {}

local function with_defaults(options)
  return {
    ring = {
      history_length = options.ring and options.ring.history_length or 10,
      storage = options.ring and options.ring.storage or "shada",
    },
    system_clipboard = {
      sync_with_ring = options.system_clipboard and options.system_clipboard.sync_with_ring or true,
    },
    highlight = {
      enabled = options.highlight and options.highlight.enabled or true,
      timer = options.highlight and options.highlight.timer or 500,
    },
  }
end

function config.setup(options)
  config.options = with_defaults(options or {})
end

return config
