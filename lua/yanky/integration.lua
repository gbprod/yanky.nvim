local yanky = require("yanky")

local integration = {}

function integration.substitute()
  return function(event)
    local is_visual = require("substitute.utils").is_visual(event.vmode)

    yanky.init_ring("p", event.register, event.count, is_visual)
  end
end

function integration.which_key_insert_put()
  return function()
    if vim.fn.getchar(1) ~= 0 then
      -- A register name is already pending (replayed by which-key or typed quickly)
      require("yanky.insert").put()
    else
      require("which-key").show({ keys = "<c-r>", mode = "i" })
    end
  end
end

return integration
