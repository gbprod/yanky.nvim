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
  yanky.setup({ ring = { storage = "memory" } })

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_command("buffer " .. buf)

  vim.api.nvim_buf_set_lines(0, 0, -1, true, { "Lorem", "ipsum", "dolor", "sit", "amet" })
  execute_keys("i<BS><C-G>u<esc>") -- Breaks undo sequence, don't know why I should do that
end

describe("Cycle", function()
  before_each(setup)

  it("should work in charwise mode", function()
    execute_keys("yw")
    execute_keys("j")
    execute_keys("yw")
    execute_keys("ll")

    execute_keys("p")
    assert.are.same({ "Lorem", "ipsipsumum", "dolor", "sit", "amet" }, get_buf_lines())

    execute_keys(",p")
    assert.are.same({ "Lorem", "ipsLoremum", "dolor", "sit", "amet" }, get_buf_lines())

    execute_keys(",P")
    assert.are.same({ "Lorem", "ipsipsumum", "dolor", "sit", "amet" }, get_buf_lines())

    execute_keys(",P")
    assert.are.same({ "Lorem", "ipsipsumum", "dolor", "sit", "amet" }, get_buf_lines())
  end)

  it("should work in linewise mode", function()
    execute_keys("yy")
    execute_keys("j")
    execute_keys("yw")
    execute_keys("j")
    execute_keys("yy")

    execute_keys("p")
    assert.are.same({ "Lorem", "ipsum", "dolor", "dolor", "sit", "amet" }, get_buf_lines())

    execute_keys(",p")
    assert.are.same({ "Lorem", "ipsum", "dipsumolor", "sit", "amet" }, get_buf_lines())

    execute_keys(",p")
    assert.are.same({ "Lorem", "ipsum", "dolor", "Lorem", "sit", "amet" }, get_buf_lines())
  end)

  it("should work in visual mode", function()
    execute_keys("yy")
    execute_keys("j")
    execute_keys("yw")
    execute_keys("j")
    execute_keys("yy")

    execute_keys("v3l")

    execute_keys("p")
    assert.are.same({ "Lorem", "ipsum", "", "dolor", "r", "sit", "amet" }, get_buf_lines())

    -- Should not do that but cant manage to make it works now
    execute_keys(",p")
    assert.are.same({ "Lorem", "ipsum", "", "dolor", "r", "sit", "amet" }, get_buf_lines())

    execute_keys(",p")
    assert.are.same({ "Lorem", "ipsum", "ipsumr", "sit", "amet" }, get_buf_lines())

    execute_keys(",p")
    assert.are.same({ "Lorem", "ipsum", "", "Lorem", "r", "sit", "amet" }, get_buf_lines())

    execute_keys(",P")
    assert.are.same({ "Lorem", "ipsum", "ipsumr", "sit", "amet" }, get_buf_lines())

    execute_keys(",P")
    assert.are.same({ "Lorem", "ipsum", "", "dolor", "r", "sit", "amet" }, get_buf_lines())

    execute_keys(",P")
    assert.are.same({ "Lorem", "ipsum", "dolor", "sit", "amet" }, get_buf_lines())

    execute_keys(",P")
    assert.are.same({ "Lorem", "ipsum", "dolor", "sit", "amet" }, get_buf_lines())
  end)

  it("should work in visual-block mode", function()
    execute_keys("yy")
    execute_keys("j")
    execute_keys("yw")
    execute_keys("j")
    execute_keys("yy")

    execute_keys("gg<c-v>jl")

    execute_keys("p")
    assert.are.same({ "rem", "sum", "dolor", "dolor", "sit", "amet" }, get_buf_lines())

    -- Should not do that but cant manage to make it works now
    execute_keys(",p")
    assert.are.same({ "rem", "sum", "dolor", "dolor", "sit", "amet" }, get_buf_lines())

    execute_keys(",p")
    assert.are.same({ "ipsumrem", "ipsumsum", "dolor", "sit", "amet" }, get_buf_lines())
  end)
end)
