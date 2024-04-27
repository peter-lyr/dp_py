local M = {}

local sta, B = pcall(require, 'dp_base')

if not sta then return print('Dp_base is required!', debug.getinfo(1)['source']) end

if B.check_plugins {
      'folke/which-key.nvim',
    } then
  return
end

function M.run_in_cmdline()
  B.cmd('!chcp 65001 && %s', B.rep(B.buf_get_name()))
end

function M.run_in_terminal()
  local file = B.rep(B.buf_get_name())
  vim.cmd 'wincmd s'
  local _sta, _ = pcall(vim.cmd, 'te')
  if not _sta then
    vim.cmd 'close'
    return
  end
  vim.api.nvim_chan_send(vim.b.terminal_job_id, file .. '\r')
  vim.api.nvim_chan_send(vim.b.terminal_job_id, 'exit\r')
  vim.cmd [[call feedkeys("i")]]
end

function M.run_in_asyncrun()
  local file = B.rep(B.buf_get_name())
  B.cmd('AsyncRun %s', file)
  vim.cmd 'copen'
  vim.cmd 'wincmd J'
  B.set_timeout(100, function()
    local lines = vim.fn.line '$' + 1
    local max = vim.fn.float2nr(vim.o.lines / 2)
    vim.api.nvim_win_set_height(0, lines > max and max or lines)
    vim.cmd 'norm zb'
  end)
end

require 'which-key'.register {
  ['<leader>p'] = { name = 'dp_py', },
  ['<leader>pr'] = { name = 'dp_py.run', },
  ['<leader>prc'] = { function() M.run_in_cmdline() end, 'dp_py.run: run_in_cmdline', silent = true, mode = { 'n', 'v', }, },
  ['<leader>prt'] = { function() M.run_in_terminal() end, 'dp_py.run: run_in_terminal', silent = true, mode = { 'n', 'v', }, },
  ['<leader>pra'] = { function() M.run_in_asyncrun() end, 'dp_py.run: run_in_asyncrun', silent = true, mode = { 'n', 'v', }, },
}

return M
