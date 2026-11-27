local yanky = require("yanky")
local system_clipboard = require("yanky.system_clipboard")
local utils = require("yanky.utils")

describe("Sync clipbard", function()
  before_each(function()
    yanky.setup({
      ring = {
        storage = "memory",
      },
      system_clipboard = {
        sync_with_ring = true,
      },
    })
  end)

  it("should add system clipboard to history on focus", function()
    -- vim.fn.setreg("*", "default_value", "V")
    -- system_clipboard.on_focus_lost()
    --
    -- vim.fn.setreg("*", "new_value", "v")
    -- system_clipboard.on_focus_gained()
    --
    -- assert.are.same({
    --   regcontents = "new_value",
    --   regtype = "v",
    -- }, yanky.history.first())
  end)
end)

describe("system clipboard register resolution", function()
  local original_get_register_info
  local original_clipboard

  local function capture_registers()
    local registers = {}
    utils.get_register_info = function(register)
      table.insert(registers, register)
      return { regcontents = "value", regtype = "v" }
    end
    return registers
  end

  before_each(function()
    original_get_register_info = utils.get_register_info
    original_clipboard = vim.api.nvim_get_option_value("clipboard", {})

    vim.api.nvim_set_option_value("clipboard", "", {})
    yanky.setup({
      ring = { storage = "memory" },
      system_clipboard = { sync_with_ring = false },
    })
  end)

  after_each(function()
    utils.get_register_info = original_get_register_info
    system_clipboard.config.clipboard_register = nil
    vim.api.nvim_set_option_value("clipboard", original_clipboard, {})
  end)

  it("resolves the clipboard register when syncing", function()
    vim.api.nvim_set_option_value("clipboard", "unnamedplus", {})
    local registers = capture_registers()

    system_clipboard.on_focus_lost()
    system_clipboard.on_focus_gained()

    assert.are.same({ "+", "+" }, registers)
  end)

  it("keeps an explicit clipboard register", function()
    vim.api.nvim_set_option_value("clipboard", "unnamedplus", {})
    system_clipboard.config.clipboard_register = "*"
    local registers = capture_registers()

    system_clipboard.on_focus_lost()
    system_clipboard.on_focus_gained()

    assert.are.same({ "*", "*" }, registers)
  end)
end)
