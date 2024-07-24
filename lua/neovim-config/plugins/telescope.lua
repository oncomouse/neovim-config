return {
	"nvim-telescope/telescope.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{ -- If encountering errors, see telescope-fzf-native README for installation instructions
			"nvim-telescope/telescope-fzf-native.nvim",

			-- `build` is used to run some command when the plugin is installed/updated.
			-- This is only run then, not every time Neovim starts up.
			build = "make",

			-- `cond` is a condition used to determine whether this plugin should be
			-- installed and loaded.
			cond = function()
				return vim.fn.executable("make") == 1
			end,
		},
		{ "nvim-telescope/telescope-file-browser.nvim" },
		{ "nvim-telescope/telescope-ui-select.nvim" },
	},
	cmd = "Telescope",
	keys = function()
		local builtin = require("telescope.builtin")
		local ivy = require("telescope.themes").get_ivy()
		return {
			{
				"<leader>sb",
				"<cmd>Telescope buffers theme=ivy<cr>",
				desc = "[S]earch [S]elect Telescope",
				mode = "n",
			},
			{
				"<leader>sh",
				"<cmd>Telescope help_tags theme=ivy<cr>",
				desc = "[S]earch [H]elp",
				mode = "n",
			},
			{
				"<leader>sk",
				"<cmd>Telescope keymaps theme=ivy<cr>",
				desc = "[S]earch [K]eymaps",
				mode = "n",
			},
			{
				"<leader>sf",
				"<cmd>Telescope find_files theme=ivy<cr>",
				desc = "[S]earch [F]iles",
				mode = "n",
			},
			{
				"<leader>sF",
				"<cmd>Telescope file_browser<cr>",
				desc = "[S]earch [F]ilesystem (browser)",
				mode = "n",
			},
			{
				"<leader>ss",
				"<cmd>Telescope builtin theme=ivy<cr>",
				desc = "[S]earch [S]elect Telescope",
				mode = "n",
			},
			{
				"<leader>sw",
				"<cmd>Telescope grep_string theme=ivy<cr>",
				desc = "[S]earch current [W]ord",
				mode = "n",
			},
			{
				"<leader>sg",
				"<cmd>Telescope live_grep theme=ivy<cr>",
				desc = "[S]earch by [G]rep",
				mode = "n",
			},
			{
				"<leader>sd",
				"<cmd>Telescope diagnostics theme=ivy<cr>",
				desc = "[S]earch [D]iagnostics",
				mode = "n",
			},
			{
				"<leader>sr",
				"<cmd>Telescope resume theme=ivy<cr>",
				desc = "[S]earch [R]esume",
				mode = "n",
			},
			{
				"<leader>s.",
				"<cmd>Telescope oldfiles theme=ivy<cr>",
				desc = '[S]earch Recent Files ("." for repeat)',
				mode = "n",
			},
			{
				"<leader><leader>",
				"<cmd>Telescope buffers theme=ivy<cr>",
				desc = "[ ] Find existing buffers",
				mode = "n",
			},
		}
	end,
	config = function()
		require("telescope").setup({
			defaults = {
				mappings = {
					i = {
						["<c-g>"] = require("telescope.actions").close,
						["<c-enter>"] = "to_fuzzy_refine",
					},
				},
			},
			-- pickers = {}
			extensions = {
				["ui-select"] = {
					require("telescope.themes").get_dropdown(),
				},
				["file_browser"] = {
					theme = "ivy",
					-- disables netrw and use telescope-file-browser in its place
					hijack_netrw = true,
					mappings = {
						["i"] = {
							-- your custom insert mode mappings
							["<c-g>"] = require("telescope.actions").close,
						},
						["n"] = {
							-- your custom normal mode mappings
						},
					},
				},
			},
		})

		-- Enable Telescope extensions if they are installed
		pcall(require("telescope").load_extension, "fzf")
		pcall(require("telescope").load_extension, "file_browser")
		pcall(require("telescope").load_extension, "ui-select")

		-- See `:help telescope.builtin`
	end,
}
