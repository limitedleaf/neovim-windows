local lazyPath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
local lazyrepo = "https://github.com/folke/lazy.nvim.git"

if not (vim.uv or vim.loop).fs_stat(lazyPath) then
  local out = vim.fn.system({ 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazyPath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { 'Failed to clone lazy.nvim:\n', 'ErrorMsg' },
      { out, 'WarningMsg' },
      { '\nPress any key to exit...' },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazyPath)

vim.g.mapleader = ' '
vim.g.maplocalleader = '\\'

require("lazy").setup({
  spec = {
    { import = 'plugins' },
  },

  install = { colorscheme = { 'everforest' } },

  checker = { enabled = true },
})