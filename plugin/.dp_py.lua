require 'dp_py'
local t = vim.fn.reltimefloat(vim.fn.reltime(StartTime))
print(string.format("%.6f: %s", t, vim.fn.fnamemodify(debug.getinfo(1)['source'], ':t:r')))