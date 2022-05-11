local highlight = {}

function highlight.setup()
  highlight.config = require("yanky.config").options.highlight
  if highlight.config.on_put then
    highlight.hl_put = vim.api.nvim_create_namespace("yanky.put")
    highlight.timer = vim.loop.new_timer()
    vim.highlight.link("YankyPut", "Search", false)
    vim.highlight.link("YankyYanked", "Search", false)
  end

  if highlight.config.on_put then
    vim.cmd(
      string.format(
        "autocmd TextYankPost * silent! lua vim.highlight.on_yank{higroup='YankyYanked', timeout=%s}",
        highlight.config.timer
      )
    )
  end
end

local function get_region()
  local start = vim.api.nvim_buf_get_mark(0, "[")
  local finish = vim.api.nvim_buf_get_mark(0, "]")

  return {
    start_row = start[1] - 1,
    start_col = start[2],
    end_row = finish[1] - 1,
    end_col = finish[2],
  }
end

function highlight.highlight_put(state)
  if not highlight.config.on_put then
    return
  end

  highlight.timer:stop()
  vim.api.nvim_buf_clear_namespace(0, highlight.hl_put, 0, -1)

  local region = get_region()

  vim.highlight.range(
    0,
    highlight.hl_put,
    "YankyPut",
    { region.start_row, region.start_col },
    { region.end_row, region.end_col },
    { regtype = vim.fn.getregtype(state.register), inclusive = true }
  )

  highlight.timer:start(
    highlight.config.timer,
    0,
    vim.schedule_wrap(function()
      vim.api.nvim_buf_clear_namespace(0, highlight.hl_put, 0, -1)
    end)
  )
end

return highlight
