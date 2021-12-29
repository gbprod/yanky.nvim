local config = {}

config.options = {}

local function with_defaults(options)
  return {
    history_length = options.history_length or 10,
  }
end

function config.setup(options)
  config.options = with_defaults(options or {})
end

return config
