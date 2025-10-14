local utils = require("yanky.utils")

describe("utils.is_osc52_active", function()
  after_each(function()
    vim.g.clipboard = nil
  end)

  it("should return false when vim.g.clipboard is nil", function()
    vim.g.clipboard = nil
    assert.is_false(utils.is_osc52_active())
  end)

  it("should return false when vim.g.clipboard has no name field", function()
    vim.g.clipboard = { copy = {}, paste = {} }
    assert.is_false(utils.is_osc52_active())
  end)

  it("should return false when clipboard name is not OSC 52", function()
    vim.g.clipboard = { name = "xclip" }
    assert.is_false(utils.is_osc52_active())
  end)

  it("should return true when clipboard name is OSC 52", function()
    vim.g.clipboard = { name = "OSC 52" }
    assert.is_true(utils.is_osc52_active())
  end)
end)

describe("utils.get_default_register", function()
  after_each(function()
    vim.g.clipboard = nil
    vim.api.nvim_set_option_value("clipboard", "", {})
  end)

  it("should return unnamed register when OSC 52 is active", function()
    vim.g.clipboard = { name = "OSC 52" }
    vim.api.nvim_set_option_value("clipboard", "unnamedplus", {})
    assert.are.equal('"', utils.get_default_register())
  end)

  it("should return unnamed register when OSC 52 is active with unnamed", function()
    vim.g.clipboard = { name = "OSC 52" }
    vim.api.nvim_set_option_value("clipboard", "unnamed", {})
    assert.are.equal('"', utils.get_default_register())
  end)
end)

describe("utils.get_register", function()
  after_each(function()
    vim.g.clipboard = nil
  end)

  it("should return unnamed register when OSC 52 is active and register is +", function()
    vim.g.clipboard = { name = "OSC 52" }
    assert.are.equal('"', utils.get_register("+"))
  end)

  it("should return unnamed register when OSC 52 is active and register is *", function()
    vim.g.clipboard = { name = "OSC 52" }
    assert.are.equal('"', utils.get_register("*"))
  end)

  it("should preserve register when OSC 52 is not active", function()
    vim.g.clipboard = nil
    assert.are.equal("+", utils.get_register("+"))
  end)

  it("should preserve non-clipboard register when OSC 52 is active", function()
    vim.g.clipboard = { name = "OSC 52" }
    assert.are.equal("a", utils.get_register("a"))
  end)
end)
