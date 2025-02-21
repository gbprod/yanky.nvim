local textobj = {
  state = nil,
}

local function get_region(regtype)
  local start = vim.api.nvim_buf_get_mark(0, "[")

  local finish = vim.api.nvim_buf_get_mark(0, "]")

  return {
    start_row = start[1],
    start_col = "V" ~= regtype and start[2] or 0,
    end_row = finish[1],
    end_col = "V" ~= regtype and finish[2] or vim.fn.col("$"),
  }
end

local function is_visual_mode()
  return nil ~= vim.fn.mode():find("v")
end

local function set_selection(startpos, endpos)
  vim.api.nvim_win_set_cursor(0, startpos)
  if is_visual_mode() then
    vim.cmd("normal! o")
  else
    vim.cmd("normal! v")
  end
  vim.api.nvim_win_set_cursor(0, endpos)
end

function textobj.save_put()
  vim.b.yanky_textobj = {
    region = get_region(vim.fn.getregtype(vim.v.register)),
    regtype = vim.fn.getregtype(vim.v.register),
  }
  vim.api.nvim_buf_attach(0, false, {
    on_lines = function(_, _, _, first_line)
      if vim.b.yanky_textobj and (first_line <= vim.b.yanky_textobj.region.end_row) then
        vim.b.yanky_textobj = nil
        return true
      end
    end,
  })
end

function textobj.last_put()
  if not require("yanky.config").options.textobj.enabled then
    vim.notify("Last put text text-object is not enabled", vim.log.levels.INFO)

    return
  end

  if nil == vim.b.yanky_textobj then
    vim.notify("No last put text-object", vim.log.levels.INFO)

    return
  end

  set_selection({
    vim.b.yanky_textobj.region.start_row,
    vim.b.yanky_textobj.region.start_col,
  }, {
    vim.b.yanky_textobj.region.end_row,
    vim.b.yanky_textobj.region.end_col,
  })
end

return textobj
