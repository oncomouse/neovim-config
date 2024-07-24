return {
	"neovim/nvim-lspconfig",
	dependencies = {
		-- Automatically install LSPs and related tools to stdpath for Neovim
		"mason.nvim",
		"williamboman/mason-lspconfig.nvim",
		{ "folke/neodev.nvim", opts = {} },
	},
	lazy = true,
}
