-- Clean path for use in a prefix comparison
---@param input string
---@return string
local function clean_path(input)
	local pth = vim.fn.fnamemodify(input, ":p")
	if vim.fn.has "win32" == 1 then
		pth = pth:gsub("/", "\\")
	end
	return pth
end

-- Checks if parser is installed with nvim-treesitter
---@param lang string
---@return boolean
local function is_installed(lang)
	local matched_parsers = vim.api.nvim_get_runtime_file("parser/" .. lang .. ".so", true) or {}
	local install_dir = require("nvim-treesitter.configs").get_parser_install_dir()
	if not install_dir then
		return false
	end
	install_dir = clean_path(install_dir)
	for _, path in ipairs(matched_parsers) do
		local abspath = clean_path(path)
		if vim.startswith(abspath, install_dir) then
			return true
		end
	end
	return false
end
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
		-- Extend or override any treesitter configs:
		local parser_configs = require("nvim-treesitter.parsers").get_parser_configs()
		for f, c in pairs(vim.g.nvim_treesitter.parser_configs) do
			parser_configs[f] = c
		end
		local ts_foldexpr_augroup_id = vim.api.nvim_create_augroup("nvim_treesitter_foldexpr", {})

		vim.api.nvim_create_autocmd("FileType", {
			pattern = vim.fn.join(vim.tbl_keys(parser_configs), ","),
			group = ts_foldexpr_augroup_id,
			callback = function()
				vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"
				vim.opt_local.foldmethod = "expr"
				local lang = require("nvim-treesitter.parsers").get_buf_lang()
				if
				    require("nvim-treesitter.parsers").get_parser_configs()[lang]
				    and not is_installed(lang)
				then
					if lang == "markdown" then
						vim.cmd("TSInstall markdown_inline")
					end
					vim.cmd(string.format("TSInstall %s", lang))
				end
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
