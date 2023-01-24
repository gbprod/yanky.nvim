local M = {}

function M.root(root)
  local f = debug.getinfo(1, "S").source:sub(2)
  return vim.fn.fnamemodify(f, ":p:h:h") .. "/" .. (root or "")
end

---@param plugin string
function M.load(plugin)
  local name = plugin:match(".*/(.*)")
  local package_root = M.root(".spec/site/pack/deps/start/")
  if not vim.loop.fs_stat(package_root .. name) then
    print("Installing " .. plugin)
    vim.fn.mkdir(package_root, "p")
    vim.fn.system({
      "git",
      "clone",
      "--depth=1",
      "https://github.com/" .. plugin .. ".git",
      package_root .. "/" .. name,
    })
  end
end

function M.setup()
  vim.cmd([[set runtimepath=$VIMRUNTIME]])
  vim.opt.runtimepath:append(M.root())
  vim.opt.packpath = { M.root(".spec/site") }

  M.load("nvim-lua/plenary.nvim")

  vim.api.nvim_set_option("clipboard", "")

  require("yanky").setup({ ring = { storage = "memory" } })
  require("yanky").register_plugs()

  vim.keymap.set("n", "p", "<Plug>(YankyPutAfter)", {})
  vim.keymap.set("n", "P", "<Plug>(YankyPutBefore)", {})
  vim.keymap.set("x", "p", "<Plug>(YankyPutAfter)", {})
  vim.keymap.set("x", "P", "<Plug>(YankyPutBefore)", {})

  vim.keymap.set("n", "gp", "<Plug>(YankyGPutAfter)", {})
  vim.keymap.set("n", "gP", "<Plug>(YankyGPutBefore)", {})
  vim.keymap.set("x", "gp", "<Plug>(YankyGPutAfter)", {})
  vim.keymap.set("x", "gP", "<Plug>(YankyGPutBefore)", {})

  vim.keymap.set("n", ",p", "<Plug>(YankyCycleForward)", {})
  vim.keymap.set("n", ",P", "<Plug>(YankyCycleBackward)", {})

  vim.keymap.set("n", "y", "<Plug>(YankyYank)", {})
  vim.keymap.set("x", "y", "<Plug>(YankyYank)", {})
end

M.setup()
