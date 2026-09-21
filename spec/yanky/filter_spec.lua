local yanky = require("yanky")
local history = require("yanky.history")

local function execute_keys(feedkeys)
  local keys = vim.api.nvim_replace_termcodes(feedkeys, true, false, true)
  vim.api.nvim_feedkeys(keys, "x!", false)
end

local function setup(filter, options)
  yanky.setup({
    ring = vim.tbl_extend("force", { storage = "memory", filter = filter }, options or {}),
  })
  history.clear()

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_command("buffer " .. buf)

  vim.api.nvim_buf_set_lines(0, 0, -1, true, { "Lorem", "   ", "dolor" })
end

local function contents()
  return vim.tbl_map(function(entry)
    return entry.regcontents
  end, history.all())
end

describe("Ring filter", function()
  it("should keep every yank when no filter is defined", function()
    setup(nil)

    execute_keys("yy")
    execute_keys("jyy")

    assert.are.same({ "   \n", "Lorem\n" }, contents())
  end)

  it("should not push entries rejected by the filter", function()
    setup(function(entry)
      return vim.trim(entry.regcontents) ~= ""
    end)

    execute_keys("yy")
    execute_keys("jyy")
    execute_keys("jyy")

    assert.are.same({ "dolor\n", "Lorem\n" }, contents())
  end)

  it("should give the yank context to the filter", function()
    local contexts = {}
    setup(function(_, context)
      table.insert(contexts, context)
      return true
    end)

    execute_keys("yy")

    assert.are.same("yank", contexts[#contexts].source)
    assert.are.same("y", contexts[#contexts].event.operator)
  end)

  it("should keep numbered registers in sync when a delete is rejected", function()
    setup(function(entry)
      return vim.trim(entry.regcontents) ~= ""
    end, { sync_with_numbered_registers = true })

    execute_keys("yy")
    execute_keys("jdd")

    assert.are.same("Lorem\n", vim.fn.getreg("1"))
  end)

  it("should filter entries pushed from the expression register", function()
    setup(function(_, context)
      return context.source ~= "expression"
    end)

    vim.fn.setreg("a", "1+1")
    execute_keys('"=@a<CR>p')

    assert.are.same({}, contents())
  end)
end)
