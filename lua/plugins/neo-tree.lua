return {
	'nvim-neo-tree/neo-tree.nvim',
	branch = 'v3.x',
	dependencies = {
		'nvim-lua/plenary.nvim',
		'MunifTanjim/nui.nvim',
		'nvim-tree/nvim-web-devicons',
	},
	lazy = false,
	config = function()
		local neotree = require 'neo-tree'
		neotree.setup {
			source_selector = { winbar = true, status_line = true } 
		}
		vim.keymap.set('n', '<leader>e', '<cmd>Neotree toggle float<CR>', { desc = 'Neotree toggle explorer' })
		vim.keymap.set('n', '<leader>b', '<cmd>Neotree toggle float buffers<CR>', { desc = 'Neotree toggle buffer explorer' })
		vim.keymap.set('n', '<leader>g', '<cmd>Neotree toggle float git_status<CR>', { desc = 'Neotree toggle git status' })
	end,
}
