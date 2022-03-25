local yanky = require("yanky")

local function get_buf_lines()
  local result = vim.api.nvim_buf_get_lines(0, 0, vim.api.nvim_buf_line_count(0), false)
  return result
end

local function execute_keys(feedkeys)
  local keys = vim.api.nvim_replace_termcodes(feedkeys, true, false, true)
  vim.api.nvim_feedkeys(keys, "x!", false)
end

local function setup()
  yanky.setup({ ring = { storage = "memory" } })

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_command("buffer " .. buf)

  vim.api.nvim_buf_set_lines(0, 0, -1, true, { "Lorem", "ipsum", "dolor", "sit", "amet" })
end

describe("Put in charwise mode", function()
  before_each(setup)

  it("should paste after word in charwise mode", function()
    execute_keys("yw")
    execute_keys("jll")
    execute_keys("p")

    assert.are.same({ "Lorem", "ipsLoremum", "dolor", "sit", "amet" }, get_buf_lines())
  end)

  it("should paste before word in charwise mode", function()
    execute_keys("lyw")
    execute_keys("jjll")
    execute_keys("P")

    assert.are.same({ "Lorem", "ipsum", "doloremor", "sit", "amet" }, get_buf_lines())
  end)

  it("should be repeatable in charwise mode", function()
    execute_keys("yw")
    execute_keys("jll")
    execute_keys("3p")

    assert.are.same({ "Lorem", "ipsLoremLoremLoremum", "dolor", "sit", "amet" }, get_buf_lines())
  end)

  it("should use specified register in charwise mode", function()
    vim.fn.setreg("a", "REGISTRED", "c")
    execute_keys("jll")
    execute_keys('"ap')

    assert.are.same({ "Lorem", "ipsREGISTREDum", "dolor", "sit", "amet" }, get_buf_lines())
  end)
end)

describe("Put in linewise mode", function()
  before_each(setup)

  it("should paste after in linewise mode", function()
    execute_keys("yy")
    execute_keys("jll")
    execute_keys("p")

    assert.are.same({ "Lorem", "ipsum", "Lorem", "dolor", "sit", "amet" }, get_buf_lines())
  end)

  it("should paste before in linewise mode", function()
    execute_keys("yy")
    execute_keys("jll")
    execute_keys("P")

    assert.are.same({ "Lorem", "Lorem", "ipsum", "dolor", "sit", "amet" }, get_buf_lines())
  end)

  it("should be repeatable in linewise mode", function()
    execute_keys("2yy")
    execute_keys("jll")
    execute_keys("3p")

    assert.are.same(
      { "Lorem", "ipsum", "Lorem", "ipsum", "Lorem", "ipsum", "Lorem", "ipsum", "dolor", "sit", "amet" },
      get_buf_lines()
    )
  end)

  it("should use specified register in linewise mode", function()
    vim.fn.setreg("b", "REGISTRED", "l")
    execute_keys("jll")
    execute_keys('"bp')

    assert.are.same({ "Lorem", "ipsum", "REGISTRED", "dolor", "sit", "amet" }, get_buf_lines())
  end)
end)

describe("Put in blocwise mode", function()
  before_each(setup)

  it("should paste after", function()
    execute_keys("<c-v>jjlly")
    execute_keys("gg^")
    execute_keys("jll")
    execute_keys("p")

    assert.are.same({ "Lorem", "ipsLorum", "dolipsor", "sitdol", "amet" }, get_buf_lines())
  end)

  it("should paste before", function()
    execute_keys("<c-v>jjlly")
    execute_keys("gg^")
    execute_keys("jll")
    execute_keys("P")

    assert.are.same({ "Lorem", "ipLorsum", "doipslor", "sidolt", "amet" }, get_buf_lines())
  end)

  it("should be repeatable", function()
    execute_keys("<c-v>jjlly")
    execute_keys("gg^")
    execute_keys("jll")
    execute_keys("3p")

    assert.are.same({ "Lorem", "ipsLorLorLorum", "dolipsipsipsor", "sitdoldoldol", "amet" }, get_buf_lines())
  end)
end)

describe("Put in visual mode", function()
  before_each(setup)

  it("should paste after", function()
    execute_keys("y3l")
    execute_keys("jvll")
    execute_keys("p")

    assert.are.same({ "Lorem", "Lorum", "dolor", "sit", "amet" }, get_buf_lines())
  end)

  it("should paste in linewise visual selection", function()
    execute_keys("y3l")
    execute_keys("jV")
    execute_keys("p")

    assert.are.same({ "Lorem", "Lor", "dolor", "sit", "amet" }, get_buf_lines())
  end)

  it("should be repeatable", function()
    execute_keys("y3l")
    execute_keys("j")
    execute_keys("vll")
    execute_keys("3p")

    assert.are.same({ "Lorem", "LorLorLorum", "dolor", "sit", "amet" }, get_buf_lines())
  end)
end)
