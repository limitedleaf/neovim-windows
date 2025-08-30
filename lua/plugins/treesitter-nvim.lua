return {
	'nvim-treesitter/nvim-treesitter',
	lazy = false,
	branch = 'master',
	build = ':TSUpdate',
	config = function()
		config = require 'nvim-treesitter.configs'
		config.setup {
			auto_install = true,
			highlight = { enable = true },
			indent = { enable = true },
			incremental_selection = { enable = true },
		}
		install = require 'nvim-treesitter.install'
		install.prefer_git = false
		install.compilers = { 'gcc' }
	end,
}
