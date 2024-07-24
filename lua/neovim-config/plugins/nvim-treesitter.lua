vim.g.nvim_treesitter = {
	installed_parser = {
		"bash",
		"bibtex",
		"c",
		"cmake",
		"comment",
		"cpp",
		"css",
		"diff",
		"dockerfile",
		"fennel",
		"fish",
		"go",
		"graphql",
		"html",
		"http",
		"java",
		"javascript",
		"jsdoc",
		"json",
		"jsonc",
		"latex",
		"lua",
		"luadoc",
		"luap",
		"make",
		"markdown",
		"markdown_inline",
		"ninja",
		"nix",
		"perl",
		"php",
		"python",
		"query",
		"r",
		"rasi",
		"regex",
		"ruby",
		"rust",
		"scss",
		"svelte",
		"tsx",
		"typescript",
		"vim",
		"vimdoc",
		"vue",
		"xml",
		"yaml",
		"zig",
	},
	parser_configs = {

		-- TODO: Use repo in https://github.com/serenadeai/tree-sitter-scss/pull/19
		scss = {
			install_info = {
				url = "https://github.com/goncharov/tree-sitter-scss",
				files = { "src/parser.c", "src/scanner.c" },
				branch = "placeholders",
				revision = "30c9dc19d3292fa8d1134373f0f0abd8547076e8",
			},
			maintainers = { "@goncharov" },
		},
	},
	line_threshold = {
		base = {
			cpp = 30000,
			javascript = 30000,
			perl = 10000,
		},
		extension = {
			cpp = 10000,
			javascript = 3000,
			perl = 3000,
		},
	}, -- Disable check for highlight, highlight usage, highlight context module
}

vim.g.nvim_treesitter.should_highlight_disable = function(lang, bufnr)
	local line_count = vim.api.nvim_buf_line_count(bufnr or 0)

	return vim.g.nvim_treesitter.line_threshold[lang] ~= nil
		and line_count > vim.g.nvim_treesitter.line_threshold[lang].base
end

vim.g.nvim_treesitter.should_buffer_higlight_disable = function()
	local ft = vim.bo.ft
	local bufnr = vim.fn.bufnr()
	return vim.g.nvim_treesitter.should_highlight_disable(ft, bufnr)
end
return {
	"nvim-treesitter/nvim-treesitter",
	cmd = "TSUpdate",
	event = { "BufReadPost", "BufNewFile" },
	opts = {
		ensure_installed = vim.g.nvim_treesitter.installed_parser,
		highlight = {
			enable = true,
			additional_vim_regex_highlighting = false,
			disable = vim.g.nvim_treesitter.should_highlight_disable,
		},
		matchup = {
			enable = vim.g.nvim_treesitter.should_buffer_higlight_disable,
		},
	},
	build = function()
		vim.cmd([[TSUpdate]])
	end,
	config = function(_, opts)
		local parser_configs = require("nvim-treesitter.parsers").get_parser_configs()
		for f, c in pairs(vim.g.nvim_treesitter.parser_configs) do
			parser_configs[f] = c
		end
		local ts_foldexpr_augroup_id = vim.api.nvim_create_augroup("nvim_treesitter_foldexpr", {})

		vim.api.nvim_create_autocmd("FileType", {
			pattern = vim.fn.join(opts.ensure_installed, ","),
			group = ts_foldexpr_augroup_id,
			callback = function()
				vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"
				vim.opt_local.foldmethod = "expr"
			end,
			desc = "Set fold method for treesitter",
		})

		require("nvim-treesitter.configs").setup(opts)
	end,
	dependencies = {
		{
			"windwp/nvim-ts-autotag",
			config = true,
		},
		{
			"JoosepAlviste/nvim-ts-context-commentstring",
			opts = {
				enable_autocmd = false,
			},
		},
		{
			"andymass/vim-matchup",
			init = function()
				vim.g.matchup_matchparen_offscreen = {
					method = "popup",
				}
			end,
		},
		{
			"oncomouse/nvim-treesitter-endwise",
			config = true,
		},
	},
}
