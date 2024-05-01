local M = {}

local sta, B = pcall(require, 'dp_base')

if not sta then return print('Dp_base is required!', debug.getinfo(1)['source']) end

M.source = B.getsource(debug.getinfo(1)['source'])
M.lua = B.getlua(M.source)

if B.check_plugins {
      'folke/which-key.nvim',
    } then
  return
end

M.py_files = require 'plenary.scandir'.scan_dir(B.get_source_dot_dir(M.source, 'py'), { hidden = true, depth = 64, add_dirs = false, })

M.pip_install_flag = '-i https://pypi.tuna.tsinghua.edu.cn/simple --trusted-host mirrors.aliyun.com'

function M.run_in()
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
end

function M.run_sel_py()
  function M._cmdline_enter(py_file)
    local head = vim.fn.fnamemodify(py_file, ':h')
    local tail = vim.fn.fnamemodify(py_file, ':t')
    local args = vim.fn.input(string.format('python %s ', tail))
    B.system_run_histadd('asyncrun', '%s && python %s %s', B.system_cd(head), tail, args)
  end

  function M.run_sel()
    if #M.py_files == 0 then
      return
    elseif #M.py_files == 1 then
      M._cmdline_enter(M.py_files[1])
    else
      B.ui_sel(M.py_files, 'sel run py', function(py_file)
        M._cmdline_enter(py_file)
      end)
    end
  end
end

function M.pip()
  function M.pip_install()
    local module = vim.fn.input 'pip install '
    B.system_run('start', 'pip install %s %s && pause', module, M.pip_install_flag)
  end

  function M.pip_uninstall()
    local module = vim.fn.input 'pip uninstall '
    B.system_run('start', 'pip uninstall %s && pause', module)
  end

  function M.pip_copycmd(install)
    local module = vim.fn.input(string.format('copy to clipboard: pip %s ', install))
    vim.fn.setreg('+',
      string.format(
        'pip %s %s %s && pause',
        install, module, M.pip_install_flag
      )
    )
  end
end

M.run_in()

require 'which-key'.register {
  ['<leader>p'] = { name = 'python', },
  ['<leader>pr'] = { name = 'python.run', },
  ['<leader>prc'] = { function() M.run_in_cmdline() end, 'python.run: run_in_cmdline', silent = true, mode = { 'n', 'v', }, },
  ['<leader>prt'] = { function() M.run_in_terminal() end, 'python.run: run_in_terminal', silent = true, mode = { 'n', 'v', }, },
  ['<leader>pra'] = { function() M.run_in_asyncrun() end, 'python.run: run_in_asyncrun', silent = true, mode = { 'n', 'v', }, },
}

M.run_sel_py()

require 'which-key'.register {
  ['<leader>prs'] = { function() M.run_sel() end, 'python.run: run_sel', silent = true, mode = { 'n', 'v', }, },
}

M.pip()

require 'which-key'.register {
  ['<leader>pp'] = { name = 'python.pip', },
  ['<leader>ppi'] = { function() M.pip_install() end, 'python.pip: pip_install', silent = true, mode = { 'n', 'v', }, },
  ['<leader>ppu'] = { function() M.pip_uninstall() end, 'python.pip: pip_uninstall', silent = true, mode = { 'n', 'v', }, },
  ['<leader>ppc'] = { name = 'python.pip.copycmd', },
  ['<leader>ppci'] = { function() M.pip_copycmd 'install' end, 'python.pip.copycmd: install', silent = true, mode = { 'n', 'v', }, },
  ['<leader>ppcu'] = { function() M.pip_copycmd 'uninstall' end, 'python.pip.copycmd: uninstall', silent = true, mode = { 'n', 'v', }, },
}

return M
