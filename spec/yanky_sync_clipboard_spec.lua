local yanky = require("yanky")

local function execute_keys(feedkeys)
  local keys = vim.api.nvim_replace_termcodes(feedkeys, true, false, true)
  vim.api.nvim_feedkeys(keys, "x!", false)
end

local function get_buf_lines()
  local result = vim.api.nvim_buf_get_lines(0, 0, vim.api.nvim_buf_line_count(0), false)
  return result
end

local function setup()
  yanky.setup()

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_command("buffer " .. buf)

  vim.api.nvim_buf_set_lines(0, 0, -1, true, { "Lorem", "ipsum", "dolor", "sit", "amet" })
end

describe("Sync clipbard", function()
  before_each(setup)

  it("should add system clipboard to history on focus", function() end)
end)
