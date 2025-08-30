return {
	'nvim-lualine/lualine.nvim',
	dependencies = { 'nvim-tree/nvim-web-devicons' },
	config = function()
		lualine = require 'lualine'
		lualine.setup {
			always_show_tabline = true,
		}
	end,
}
