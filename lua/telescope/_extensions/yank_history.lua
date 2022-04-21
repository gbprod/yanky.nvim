local telescope = require("telescope")
local get_exports = require("yanky.telescope.yank_history").get_exports

return telescope.register_extension({
  exports = get_exports(),
})
