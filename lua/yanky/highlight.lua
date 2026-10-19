local highlight = {}

-- Use the non-deprecated `vim.hl` if available.
vim.hl = vim.hl or vim.highlight

local function hl_op(opts)
  if vim.hl.hl_op then
    return vim.hl.hl_op(opts)
  end

  return vim.hl.on_yank(opts)
end

function highlight.setup()
  highlight.config = require("yanky.config").options.highlight
  if highlight.config.on_put then
    highlight.hl_put = vim.api.nvim_create_namespace("yanky.put")
    highlight.timer = vim.loop.new_timer()

    vim.api.nvim_set_hl(0, "YankyPut", { link = "Search", default = true })
  end

  if highlight.config.on_yank then
    vim.api.nvim_create_autocmd("TextYankPost", {
      pattern = "*",
      callback = function(_)
        pcall(hl_op, { higroup = "YankyYanked", timeout = highlight.config.timer })
      end,
    })

    vim.api.nvim_set_hl(0, "YankyYanked", { link = "Search", default = true })
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

local function highlight_range(start, finish, opts)
  if not highlight.config.on_put then
    return
  end

  highlight.timer:stop()
  vim.api.nvim_buf_clear_namespace(0, highlight.hl_put, 0, -1)

  vim.hl.range(0, highlight.hl_put, "YankyPut", start, finish, opts)

  highlight.timer:start(
    highlight.config.timer,
    0,
    vim.schedule_wrap(function()
      vim.api.nvim_buf_clear_namespace(0, highlight.hl_put, 0, -1)
    end)
  )
end

function highlight.highlight_put(state)
  local region = get_region()

  highlight_range(
    { region.start_row, region.start_col },
    { region.end_row, region.end_col },
    { regtype = vim.fn.getregtype(state.register), inclusive = true }
  )
end

function highlight.highlight_insert_put(state)
  highlight_range({ state.start_row, state.start_col }, { state.end_row, state.end_col }, { regtype = "v" })
end

return highlight
