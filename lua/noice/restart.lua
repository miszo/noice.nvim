local M = {}

local enter = "<CR>"
local restart = "<C-U>lua require('noice.restart').confirm()<CR>"

M._enabled = false
M._previous = nil ---@type table?

function M.matches(cmdtype, cmdline)
  return cmdtype == ":" and cmdline == "restart"
end

function M.expand(cmdtype, cmdline)
  cmdtype = cmdtype or vim.fn.getcmdtype()
  cmdline = cmdline or vim.fn.getcmdline()
  return M.matches(cmdtype, cmdline) and restart or enter
end

---@param deps? {confirm?: fun(message:string, choices:string, default:number):number, restart?: fun()}
function M.confirm(deps)
  deps = deps or {}
  local confirm = deps.confirm or vim.fn.confirm
  local restart_nvim = deps.restart or function()
    vim.cmd.restart()
  end
  if confirm("Restart Neovim?", "&Yes\n&No", 1) == 1 then
    restart_nvim()
  end
end

---@param supported? boolean
function M.enable(supported)
  supported = supported == nil and vim.fn.has("nvim-0.12") == 1 or supported
  if M._enabled or not supported then
    return
  end
  M._enabled = true
  M._previous = vim.fn.maparg(enter, "c", false, true)
  vim.keymap.set("c", enter, M.expand, { expr = true })
end

function M.disable()
  if not M._enabled then
    return
  end
  M._enabled = false
  vim.keymap.del("c", enter)
  if M._previous and not vim.tbl_isempty(M._previous) then
    vim.fn.mapset("c", false, M._previous)
  end
  M._previous = nil
end

return M
