-- User settings
vim.opt.tabstop = 3
vim.opt.shiftwidth = 3
vim.opt.number = true
vim.keymap.set("i", ";;", "<Esc>", { noremap = true, silent = true })
vim.keymap.set("v", ";;", "<Esc>", { noremap = true, silent = true })

-- Internal Settings
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.python3_host_prog = vim.fn.expand("~\\scoop\\apps\\python\\current\\python.exe")

