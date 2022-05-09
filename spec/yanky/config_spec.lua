describe("Config", function()
  it("should get defaults values", function()
    local config = require("yanky.config")
    config.setup({})

    assert.are.same({
      ring = {
        history_length = 100,
        storage = "shada",
        sync_with_numbered_registers = true,
      },
      system_clipboard = {
        sync_with_ring = true,
      },
      highlight = {
        on_put = true,
        on_yank = true,
        timer = 500,
      },
      preserve_cursor_position = {
        enabled = true,
      },
      picker = {
        select = {
          action = nil,
        },
        telescope = {
          mappings = nil,
        },
      },
    }, config.options)
  end)

  it("should get new values", function()
    local config = require("yanky.config")

    config.setup({
      ring = {
        history_length = 0,
        storage = "memory",
        sync_with_numbered_registers = false,
      },
      system_clipboard = {
        sync_with_ring = false,
      },
      highlight = {
        on_put = false,
        on_yank = false,
        timer = 0,
      },
      preserve_cursor_position = {
        enabled = false,
      },
      picker = {
        select = {
          action = nil,
        },
        telescope = {
          mappings = nil,
        },
      },
    })
    assert.are.same({
      ring = {
        history_length = 0,
        storage = "memory",
        sync_with_numbered_registers = false,
      },
      system_clipboard = {
        sync_with_ring = false,
      },
      highlight = {
        on_put = false,
        on_yank = false,
        timer = 0,
      },
      preserve_cursor_position = {
        enabled = false,
      },
      picker = {
        select = {
          action = nil,
        },
        telescope = {
          mappings = nil,
        },
      },
    }, config.options)
  end)
end)
