return {
	-- Base requirements:
	{ "nvim-lua/plenary.nvim", lazy = true },
	-- Editor Enhancements:
	{
		"tpope/vim-sleuth",
		init = function()
			vim.g.sleuth_org_heuristics = false
		end,
		event = { "BufNewFile", "BufReadPost", "BufFilePost", "FileType" },
	}, -- Automatically set indent

	-- Mappings and Commands:
	"tpope/vim-rsi", -- Readline mappings
	{
		"haya14busa/vim-asterisk",
		keys = {
			{
				"*",
				"<Plug>(asterisk-z*)",
				desc = "Search forward for the [count]'th occurrence of the word nearest to the cursor",
			},
			{
				"#",
				"<Plug>(asterisk-z#)",
				desc = "Search backward for the [count]'th occurrence of the word nearest to the cursor",
			},
			{
				"g*",
				"<Plug>(asterisk-gz*)",
				desc =
				"Search forward for the [count]'th occurrence of the word (or part of a word) nearest to the cursor",
			},
			{
				"g#",
				"<Plug>(asterisk-gz#)",
				desc =
				"Search backward for the [count]'th occurrence of the word (or part of a word) nearest to the cursor",
			},
		},
		init = function()
			vim.g["asterisk#keeppos"] = 1
		end,
	}, -- Fancy * and # bindings

	{
		"dstein64/vim-startuptime",
		cmd = "StartupTime",
		init = function()
			vim.g.startuptime_tries = 10
		end,
	}, -- :StartupTime for profiling startup

	{
		"oncomouse/lazygit.nvim",
		cmd = "LazyGit",
	}, -- :LazyGit for calling lazygit
}
