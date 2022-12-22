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

  vim.api.nvim_buf_set_lines(0, 0, -1, true, {
    "void test() {",
    "    int a = 1;",
    "    int b = 2;",
    "    for (int i = 0; i < 10; ++i) {",
    "        cout << a;",
    "        cout << b;",
    "    }",
    "}",
  })

  vim.cmd("set ft=c")
end

describe("Special Put", function()
  before_each(setup)

  it("should PutAfterFilter", function()
    vim.cmd("5")
    execute_keys("2yy")
    vim.cmd("3")
    vim.cmd('execute "normal \\<Plug>(YankyPutAfterFilter)"')
    assert.are.same({
      "void test() {",
      "    int a = 1;",
      "    int b = 2;",
      "    cout << a;",
      "    cout << b;",
      "    for (int i = 0; i < 10; ++i) {",
      "        cout << a;",
      "        cout << b;",
      "    }",
      "}",
    }, get_buf_lines())

    assert.are.same({ 4, 4 }, vim.api.nvim_win_get_cursor(0))
  end)

  it("should GPutBeforeFilter", function()
    vim.cmd("5")
    execute_keys("2yy")
    vim.cmd("4")
    vim.cmd('execute "normal \\<Plug>(YankyGPutBeforeFilter)"')
    assert.are.same({
      "void test() {",
      "    int a = 1;",
      "    int b = 2;",
      "    cout << a;",
      "    cout << b;",
      "    for (int i = 0; i < 10; ++i) {",
      "        cout << a;",
      "        cout << b;",
      "    }",
      "}",
    }, get_buf_lines())

    assert.are.same({ 6, 0 }, vim.api.nvim_win_get_cursor(0))
  end)
end)
