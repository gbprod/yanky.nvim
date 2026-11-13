local yanky = require("yanky")

local function execute_keys(feedkeys)
  local keys = vim.api.nvim_replace_termcodes(feedkeys, true, false, true)
  vim.api.nvim_feedkeys(keys, "x", false)
end

local function get_buf_lines()
  return vim.api.nvim_buf_get_lines(0, 0, vim.api.nvim_buf_line_count(0), false)
end

local function setup()
  yanky.setup({ ring = { storage = "memory" } })
  yanky.history.clear()

  vim.keymap.set("i", "<c-r>", "<Plug>(YankyInsertPut)", {})
  vim.keymap.set("i", "<c-p>", "<Plug>(YankyInsertCycleForward)", {})
  vim.keymap.set("i", "<c-n>", "<Plug>(YankyInsertCycleBackward)", {})

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_command("buffer " .. buf)

  vim.api.nvim_buf_set_lines(0, 0, -1, true, { "Lorem", "ipsum", "dolor", "sit", "amet" })
  execute_keys("i<BS><C-G>u<esc>") -- Breaks undo sequence
end

describe("Insert put", function()
  before_each(setup)

  after_each(function()
    vim.keymap.del("i", "<c-r>")
    vim.keymap.del("i", "<c-p>")
    vim.keymap.del("i", "<c-n>")
  end)

  it("should put register in insert mode", function()
    execute_keys('"ayw')
    execute_keys("jyw")
    execute_keys('jllia<c-r>"b<c-r>ac<esc>')

    assert.are.same({ "Lorem", "ipsum", "doaipsumbLoremclor", "sit", "amet" }, get_buf_lines())
  end)

  it("should cycle charwise", function()
    execute_keys("yw")
    execute_keys("jyw")
    execute_keys("jyw")
    execute_keys("jll")

    execute_keys('i<c-r>"<esc>')
    assert.are.same({ "Lorem", "ipsum", "dolor", "sidolort", "amet" }, get_buf_lines())

    execute_keys('ui<c-r>"<c-p><esc>')
    assert.are.same({ "Lorem", "ipsum", "dolor", "siipsumt", "amet" }, get_buf_lines())

    execute_keys('ui<c-r>"<c-p><c-p>X<esc>')
    assert.are.same({ "Lorem", "ipsum", "dolor", "siLoremXt", "amet" }, get_buf_lines())

    execute_keys('ui<c-r>"<c-p><c-p><c-p><c-n><esc>')
    assert.are.same({ "Lorem", "ipsum", "dolor", "siipsumt", "amet" }, get_buf_lines())
  end)

  it("should cycle with multiline content", function()
    execute_keys("yy")
    execute_keys("jyj")
    execute_keys('Gi<c-r>"<c-p>X<esc>')

    assert.are.same({ "Lorem", "ipsum", "dolor", "sit", "Lorem", "Xamet" }, get_buf_lines())

    execute_keys('ugg0i<c-r>"Y<esc>')
    assert.are.same({ "ipsum", "dolor", "YLorem", "ipsum", "dolor", "sit", "amet" }, get_buf_lines())
  end)

  it("should not cycle after typing", function()
    execute_keys("yw")
    execute_keys("jyw")
    execute_keys('jA<c-r>"X<c-p><esc>')

    assert.are.same({ "Lorem", "ipsum", "doloripsumX", "sit", "amet" }, get_buf_lines())
  end)

  it("should not cycle after moving", function()
    execute_keys("yw")
    execute_keys("jyw")
    execute_keys('jA<c-r>"<left><c-p><esc>')

    assert.are.same({ "Lorem", "ipsum", "doloripsum", "sit", "amet" }, get_buf_lines())
  end)

  describe("cancel", function()
    -- CursorMovedI is not triggered while keys are pending in typeahead, fire
    -- it as neovim does when each key is typed separately.
    before_each(function()
      vim.keymap.set("i", "<F2>", function()
        vim.api.nvim_exec_autocmds("CursorMovedI", { buffer = 0 })
      end, {})
    end)

    after_each(function()
      vim.keymap.del("i", "<F2>")
    end)

    it("should still cycle after its own cursor update", function()
      execute_keys("yw")
      execute_keys("jyw")
      execute_keys('jA<c-r>"<F2><c-p><esc>')

      assert.are.same({ "Lorem", "ipsum", "dolorLorem", "sit", "amet" }, get_buf_lines())
    end)

    it("should not cycle after moving back to the put end", function()
      execute_keys("yw")
      execute_keys("jyw")
      execute_keys('jA<c-r>"<left><F2><right><F2><c-p><esc>')

      assert.are.same({ "Lorem", "ipsum", "doloripsum", "sit", "amet" }, get_buf_lines())
    end)

    it("should not cycle after leaving insert mode", function()
      execute_keys("yw")
      execute_keys("jyw")
      execute_keys('jA<c-r>"<esc>')
      execute_keys("a<c-p><esc>")

      assert.are.same({ "Lorem", "ipsum", "doloripsum", "sit", "amet" }, get_buf_lines())
    end)
  end)

  it("should insert nothing with black hole register", function()
    execute_keys("yw")
    execute_keys("jA<c-r>_<esc>")

    assert.are.same({ "Lorem", "ipsum", "dolor", "sit", "amet" }, get_buf_lines())
  end)

  it("should not cycle after black hole register", function()
    execute_keys("yw")
    execute_keys("jyw")
    execute_keys('jA<c-r>"<c-r>_<c-p><esc>')

    assert.are.same({ "Lorem", "ipsum", "doloripsum", "sit", "amet" }, get_buf_lines())
  end)

  it("should forward expression register to native insert", function()
    execute_keys("A<c-r>=1+1<cr><esc>")

    assert.are.same({ "Lorem2", "ipsum", "dolor", "sit", "amet" }, get_buf_lines())
  end)
end)
