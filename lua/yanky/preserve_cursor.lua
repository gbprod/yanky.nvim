local preserve_cursor = {}

preserve_cursor.state = {
  cusor_position = nil,
  win_state = nil,
}

function preserve_cursor.setup()
  preserve_cursor.config = require("yanky.config").options.preserve_cursor_position
end

function preserve_cursor.on_yank()
  if not preserve_cursor.config.enabled then
    return
  end

  if nil ~= preserve_cursor.state.cusor_position then
    vim.fn.setpos(".", preserve_cursor.state.cusor_position)
    vim.fn.winrestview(preserve_cursor.state.win_state)

    preserve_cursor.state = {
      cusor_position = nil,
      win_state = nil,
    }
  end
end

function preserve_cursor.yank()
  if not preserve_cursor.config.enabled then
    return
  end

  preserve_cursor.state = {
    cusor_position = vim.fn.getpos("."),
    win_state = vim.fn.winsaveview(),
  }

  vim.api.nvim_buf_attach(0, false, {
    on_lines = function()
      preserve_cursor.state = {
        cusor_position = nil,
        win_state = nil,
      }

      return true
    end,
  })
end

return preserve_cursor
