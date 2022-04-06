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

local function get_regions(regtype)
  local start = vim.api.nvim_buf_get_mark(0, "[")
  local finish = vim.api.nvim_buf_get_mark(0, "]")

  if regtype:match("^" .. vim.api.nvim_replace_termcodes("<c-v>", true, false, true)) then
    local regions = {}

    for row = start[1], finish[1], 1 do
      local current_row_len = vim.fn.getline(row):len() - 1

      table.insert(regions, {
        start_row = row,
        start_col = start[2],
        end_row = row,
        end_col = current_row_len >= finish[2] and finish[2] or current_row_len,
      })
    end

    return regions
  end

  local end_row_len = vim.fn.getline(finish[1]):len() - 1

  return {
    {
      start_row = start[1],
      start_col = start[2],
      end_row = finish[1],
      end_col = (end_row_len >= finish[2]) and finish[2] or end_row_len,
    },
  }
end

local function highlight_regions(regions, hl_group, ns_id)
  for _, region in ipairs(regions) do
    for line = region.start_row, region.end_row do
      vim.api.nvim_buf_add_highlight(
        0,
        ns_id,
        hl_group,
        line - 1,
        line == region.start_row and region.start_col or 0,
        line == region.end_row and region.end_col + 1 or -1
      )
    end
  end
end

function highlight.highlight_put(state)
  if not highlight.config.on_put then
    return
  end

  highlight.timer:stop()
  vim.api.nvim_buf_clear_namespace(0, highlight.hl_put, 0, -1)

  local regions = get_regions(vim.fn.getregtype(state.register))

  highlight_regions(regions, "YankyPut", highlight.hl_put)
  highlight.timer:start(
    highlight.config.timer,
    0,
    vim.schedule_wrap(function()
      vim.api.nvim_buf_clear_namespace(0, highlight.hl_put, 0, -1)
    end)
  )
end

return highlight
