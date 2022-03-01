local config = {}

config.options = {}

local function with_defaults(options)
  return {
    history_length = options.history_length or 10,
    highlight = {
      enabled = options.highlight and options.highlight.enabled or false,
      timer = options.highlight and options.highlight.timer or 500,
    },
  }
end

function config.setup(options)
  config.options = with_defaults(options or {})
end

return config
