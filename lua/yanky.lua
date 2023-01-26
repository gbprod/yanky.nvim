local utils = require("yanky.utils")
local highlight = require("yanky.highlight")
local system_clipboard = require("yanky.system_clipboard")
local preserve_cursor = require("yanky.preserve_cursor")
local picker = require("yanky.picker")

local yanky = {}

yanky.ring = {
  state = nil,
  is_cycling = false,
  callback = nil,
}

yanky.direction = {
  FORWARD = 1,
  BACKWARD = -1,
}

yanky.type = {
  PUT_BEFORE = "P",
  PUT_AFTER = "p",
  GPUT_BEFORE = "gP",
  GPUT_AFTER = "gp",
  PUT_INDENT_AFTER = "]p",
  PUT_INDENT_BEFORE = "[p",
}

function yanky.setup(options)
  yanky.config = require("yanky.config")
  yanky.config.setup(options)

  yanky.history = require("yanky.history")
  yanky.history.setup()

  system_clipboard.setup()
  highlight.setup()
  preserve_cursor.setup()
  picker.setup()

  local yanky_augroup = vim.api.nvim_create_augroup("Yanky", { clear = true })
  vim.api.nvim_create_autocmd("TextYankPost", {
    group = yanky_augroup,
    pattern = "*",
    callback = function(_)
      yanky.on_yank()
    end,
  })
  vim.api.nvim_create_autocmd("VimEnter", {
    group = yanky_augroup,
    pattern = "*",
    callback = yanky.init_history,
  })

  vim.api.nvim_create_user_command("YankyClearHistory", yanky.clear_history, {})
end

function yanky.init_history()
  yanky.history.push(utils.get_register_info(utils.get_default_register()))
  yanky.history.sync_with_numbered_registers()
end

local function do_put(state, _)
  if state.is_visual then
    vim.cmd([[execute "normal! \<esc>"]])
  end

  local ok, val = pcall(
    vim.cmd,
    string.format(
      'silent normal! %s"%s%s%s',
      state.is_visual and "gv" or "",
      state.register ~= "=" and state.register or "=" .. vim.api.nvim_replace_termcodes("<CR>", true, false, true),
      state.count,
      state.type
    )
  )
  if not ok then
    vim.notify(val, vim.log.levels.WARN)
    return
  end

  highlight.highlight_put(state)
end

function yanky.put(type, is_visual, callback)
  if not vim.tbl_contains(vim.tbl_values(yanky.type), type) then
    vim.notify("Invalid type " .. type, vim.log.levels.ERROR)
    return
  end

  yanky.ring.state = nil
  yanky.ring.is_cycling = false
  yanky.ring.callback = callback or do_put

  -- On Yank event is not triggered when put from expression register,
  -- To allows cycling, we must store value here
  if vim.v.register == "=" then
    local entry = utils.get_register_info("=")
    entry.filetype = vim.bo.filetype

    yanky.history.push(entry)
  end

  yanky.init_ring(type, vim.v.register, vim.v.count, is_visual, yanky.ring.callback)
end

function yanky.clear_ring()
  if yanky.can_cycle() and nil ~= yanky.ring.state.augroup then
    vim.api.nvim_clear_autocmds({ group = yanky.ring.state.augroup })
  end

  yanky.ring.state = nil
  yanky.ring.is_cycling = false
end

function yanky.attach_cancel()
  if yanky.config.options.ring.cancel_event == "move" then
    vim.schedule(function()
      yanky.ring.state.augroup = vim.api.nvim_create_augroup("YankyRingClear", { clear = true })
      vim.api.nvim_create_autocmd("CursorMoved", {
        group = yanky.ring.state.augroup,
        buffer = 0,
        callback = yanky.clear_ring,
      })
    end)
  else
    vim.api.nvim_buf_attach(0, false, {
      on_lines = function(_)
        yanky.clear_ring()

        return true
      end,
    })
  end
end

function yanky.init_ring(type, register, count, is_visual, callback)
  register = (register ~= '"' and register ~= "_") and register or utils.get_default_register()

  local reg_content = vim.fn.getreg(register)
  if nil == reg_content or "" == reg_content then
    vim.notify(string.format('Register "%s" is empty', register), vim.log.levels.WARN)
    return
  end

  local new_state = {
    type = type,
    register = register,
    count = count > 0 and count or 1,
    is_visual = is_visual,
    use_repeat = callback == nil,
  }

  if nil ~= callback then
    callback(new_state, do_put)
  end

  yanky.ring.state = new_state
  yanky.ring.is_cycling = false

  yanky.attach_cancel()
end

function yanky.can_cycle()
  return nil ~= yanky.ring.state
end

function yanky.cycle(direction)
  if not yanky.can_cycle() then
    vim.notify("Your last action was not put, ignoring cycle", vim.log.levels.INFO)
    return
  end

  direction = direction or yanky.direction.FORWARD
  if not vim.tbl_contains(vim.tbl_values(yanky.direction), direction) then
    vim.notify("Invalid direction for cycle", vim.log.levels.ERROR)
    return
  end

  if nil ~= yanky.ring.state.augroup then
    vim.api.nvim_clear_autocmds({ group = yanky.ring.state.augroup })
  end

  if not yanky.ring.is_cycling then
    yanky.history.reset()

    local reg = utils.get_register_info(yanky.ring.state.register)
    local first = yanky.history.first()
    if reg.regcontents == first.regcontents and reg.regtype == first.regtype then
      yanky.history.skip()
    end
  end

  local new_state = yanky.ring.state

  local next_content
  if direction == yanky.direction.FORWARD then
    next_content = yanky.history.next()
    if nil == next_content then
      vim.notify("Reached oldest item", vim.log.levels.INFO)
      return
    end
  else
    next_content = yanky.history.previous()
    if nil == next_content then
      vim.notify("Reached first item", vim.log.levels.INFO)
      return
    end
  end

  yanky.ring.state.register = yanky.ring.state.register ~= "=" and yanky.ring.state.register
    or utils.get_default_register()

  utils.use_temporary_register(yanky.ring.state.register, next_content, function()
    if new_state.use_repeat then
      local ok, val = pcall(vim.cmd, "silent normal! u.")
      if not ok then
        vim.notify(val, vim.log.levels.WARN)
        return
      end
      highlight.highlight_put(new_state)
    else
      local ok, val = pcall(vim.cmd, "silent normal! u")
      if not ok then
        vim.notify(val, vim.log.levels.WARN)
        return
      end
      yanky.ring.callback(new_state, do_put)
    end
  end)

  yanky.ring.is_cycling = true
  yanky.ring.state = new_state

  yanky.attach_cancel()
end

function yanky.on_yank()
  if "_" == vim.v.register then
    return
  end

  -- Only historize first delete in visual mode
  if vim.v.event.visual and vim.v.event.operator == "d" and yanky.ring.is_cycling then
    return
  end
  local entry = utils.get_register_info(vim.v.event.regname)
  entry.filetype = vim.bo.filetype

  yanky.history.push(entry)

  preserve_cursor.on_yank()
end

function yanky.yank(options)
  options = options or {}
  preserve_cursor.yank()

  return string.format("%sy", options.register and '"' .. options.register or "")
end

function yanky.clear_history()
  yanky.history.clear()
end

function yanky.register_plugs()
  local yanky_wrappers = require("yanky.wrappers")

  vim.keymap.set("n", "<Plug>(YankyCycleForward)", function()
    yanky.cycle(1)
  end, { silent = true })

  vim.keymap.set("n", "<Plug>(YankyCycleBackward)", function()
    yanky.cycle(-1)
  end, { silent = true })

  vim.keymap.set({ "n", "x" }, "<Plug>(YankyYank)", yanky.yank, { silent = true, expr = true })

  for type, type_text in pairs({
    p = "PutAfter",
    P = "PutBefore",
    gp = "GPutAfter",
    gP = "GPutBefore",
    ["]p"] = "PutIndentAfter",
    ["[p"] = "PutIndentBefore",
  }) do
    vim.keymap.set("n", string.format("<Plug>(Yanky%s)", type_text), function()
      yanky.put(type, false)
    end, { silent = true })

    vim.keymap.set("x", string.format("<Plug>(Yanky%s)", type_text), function()
      yanky.put(type, true)
    end, { silent = true })

    vim.keymap.set("n", string.format("<Plug>(Yanky%sJoined)", type_text), function()
      yanky.put(type, false, yanky_wrappers.trim_and_join_lines())
    end, { silent = true })

    vim.keymap.set("x", string.format("<Plug>(Yanky%sJoined)", type_text), function()
      yanky.put(type, true, yanky_wrappers.trim_and_join_lines())
    end, { silent = true })

    vim.keymap.set("n", string.format("<Plug>(Yanky%sLinewise)", type_text), function()
      yanky.put(type, false, yanky_wrappers.linewise())
    end, { silent = true })

    vim.keymap.set("x", string.format("<Plug>(Yanky%sLinewise)", type_text), function()
      yanky.put(type, true, yanky_wrappers.linewise())
    end, { silent = true })

    vim.keymap.set("n", string.format("<Plug>(Yanky%sLinewiseJoined)", type_text), function()
      yanky.put(type, false, yanky_wrappers.linewise(yanky_wrappers.trim_and_join_lines()))
    end, { silent = true })

    vim.keymap.set("x", string.format("<Plug>(Yanky%sLinewiseJoined)", type_text), function()
      yanky.put(type, true, yanky_wrappers.linewise(yanky_wrappers.trim_and_join_lines()))
    end, { silent = true })

    vim.keymap.set("n", string.format("<Plug>(Yanky%sCharwise)", type_text), function()
      yanky.put(type, false, yanky_wrappers.charwise())
    end, { silent = true })

    vim.keymap.set("x", string.format("<Plug>(Yanky%sCharwise)", type_text), function()
      yanky.put(type, true, yanky_wrappers.charwise())
    end, { silent = true })

    vim.keymap.set("n", string.format("<Plug>(Yanky%sCharwiseJoined)", type_text), function()
      yanky.put(type, false, yanky_wrappers.charwise(yanky_wrappers.trim_and_join_lines()))
    end, { silent = true })

    vim.keymap.set("x", string.format("<Plug>(Yanky%sCharwiseJoined)", type_text), function()
      yanky.put(type, true, yanky_wrappers.charwise(yanky_wrappers.trim_and_join_lines()))
    end, { silent = true })

    vim.keymap.set("n", string.format("<Plug>(Yanky%sBlockwise)", type_text), function()
      yanky.put(type, false, yanky_wrappers.blockwise())
    end, { silent = true })

    vim.keymap.set("x", string.format("<Plug>(Yanky%sBlockwise)", type_text), function()
      yanky.put(type, true, yanky_wrappers.blockwise())
    end, { silent = true })

    vim.keymap.set("n", string.format("<Plug>(Yanky%sBlockwiseJoined)", type_text), function()
      yanky.put(type, false, yanky_wrappers.blockwise(yanky_wrappers.trim_and_join_lines()))
    end, { silent = true })

    vim.keymap.set("x", string.format("<Plug>(Yanky%sBlockwiseJoined)", type_text), function()
      yanky.put(type, true, yanky_wrappers.blockwise(yanky_wrappers.trim_and_join_lines()))
    end, { silent = true })

    for change, change_text in pairs({ [">>"] = "ShiftRight", ["<<"] = "ShiftLeft", ["=="] = "Filter" }) do
      vim.keymap.set("n", string.format("<Plug>(Yanky%s%s)", type_text, change_text), function()
        yanky.put(type, false, yanky_wrappers.linewise(yanky_wrappers.change(change)))
      end, { silent = true })

      vim.keymap.set("x", string.format("<Plug>(Yanky%s%s)", type_text, change_text), function()
        yanky.put(type, true, yanky_wrappers.linewise(yanky_wrappers.change(change)))
      end, { silent = true })

      vim.keymap.set("n", string.format("<Plug>(Yanky%s%sJoined)", type_text, change_text), function()
        yanky.put(
          type,
          false,
          yanky_wrappers.linewise(yanky_wrappers.trim_and_join_lines(yanky_wrappers.change(change)))
        )
      end, { silent = true })

      vim.keymap.set("x", string.format("<Plug>(Yanky%s%sJoined)", type_text, change_text), function()
        yanky.put(
          type,
          true,
          yanky_wrappers.linewise(yanky_wrappers.trim_and_join_lines(yanky_wrappers.change(change)))
        )
      end, { silent = true })
    end
  end
end

return yanky
