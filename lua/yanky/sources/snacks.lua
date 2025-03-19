local utils = require("yanky.utils")

local M = {}

local format_title = function(item)
  local regtype_map = {
    v = "charwise",
    V = "linewise",
  }
  local regtype_text = regtype_map[item.regtype] or "blockwise"

  if item.filetype == nil then
    return regtype_text
  end

  return regtype_text .. " (" .. item.filetype .. ")"
end

M.config = {
  title = "Yank History",
  finder = function()
    local items = {}
    for index, value in pairs(require("yanky.history").all()) do
      value.key = index
      value.text = tostring(value.regcontents)
      items[#items + 1] = value
    end
    return items
  end,
  win = {
    input = {
      keys = {
        ["<c-y>"] = { "set_default_register", mode = { "n", "i" } },
        ["<c-x>"] = { "delete", mode = { "n", "i" } },
      },
    },
  },
  format = function(item)
    return {
      {
        Snacks.picker.util.align(tostring(item.idx), #tostring(item.idx), { align = "right" }),
        "SnacksPickerIdx",
        virtual = true,
      },
      { " ", virtual = true },
      { item.regcontents },
    }
  end,
  preview = function(ctx)
    ctx.preview:reset()
    ctx.preview:set_lines(ctx.item.regcontents and vim.split(ctx.item.regcontents, "\n") or {})
    ctx.preview:set_title(format_title(ctx.item))
    ctx.preview:highlight({ ft = ctx.item.filetype or "text" })
  end,
  actions = {
    confirm = function(picker)
      picker:close()
      local selected = picker:selected({ fallback = true })

      if vim.tbl_count(selected) == 1 then
        require("yanky.picker").actions.put("p", false)(selected[1])
        return
      end
      local content = {
        regcontents = "",
        regtype = "V",
      }
      for _, current in ipairs(selected) do
        content.regcontents = content.regcontents .. current.regcontents
        if current.regtype == "v" then
          content.regcontents = content.regcontents .. "\n"
        end
      end
      require("yanky.picker").actions.put("p", false)(content)
    end,
    set_default_register = function(picker)
      picker:close()
      require("yanky.picker").actions.set_register(utils.get_default_register())(picker:current())
    end,
    delete = function(picker)
      local selected = picker:selected({ fallback = true })
      -- sort from greater to lower index as it will not affect indexes
      table.sort(selected, function(a, b)
        return a.idx > b.idx
      end)
      for _, current in ipairs(selected) do
        current.history_index = current.idx
        require("yanky.picker").actions.delete()(current)
      end
      picker.list:set_selected()
      picker:find()
    end,
  },
}

function M.pick(opts)
  if Snacks == nil then
    return
  end

  return Snacks.picker.pick("yanky", opts)
end

return M
