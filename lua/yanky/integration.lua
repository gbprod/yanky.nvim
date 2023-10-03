local yanky = require("yanky")

local integration = {}

function integration.substitute()
  return function(event)
    local is_visual = require("substitute.utils").is_visual(event.vmode)

    yanky.init_ring("p", event.register, event.count, is_visual)
  end
end

return integration
