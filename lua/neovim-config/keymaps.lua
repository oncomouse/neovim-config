local M = {}

function M.setup()
	-- Navigation in insert mode:
	vim.keymap.set("i", "<C-a>", function()
		local sc = vim.fn.col(".")
		vim.cmd("normal! ^")
		if vim.fn.col(".") == sc then
			vim.cmd("normal! 0")
		end
	end, { silent = true, desc = "Move to start of line" })
	vim.keymap.set("i", "<C-e>", "<End>", { silent = true, desc = "Move to end of line" })
	vim.keymap.set("i", "<C-b>", "<Left>", { desc = "Move back one character" })
	vim.keymap.set("i", "<C-f>", "<Right>", { desc = "Move forward one character" })
	local function move_word(backwards)
		return function()
			local _, new_position =
				unpack(vim.fn.searchpos(backwards and [[\<]] or [[\>]], backwards and "bn" or "n", vim.fn.line(".")))
			local row, col = unpack(vim.api.nvim_win_get_cursor(0))
			if new_position == 0 then
				col = backwards and 0 or #vim.api.nvim_get_current_line()
			else
				col = new_position - 1
			end
			vim.api.nvim_win_set_cursor(0, { row, col })
		end
	end
	vim.keymap.set("i", "<A-b>", move_word(true), { desc = "Move back one word" })
	vim.keymap.set("i", "<A-f>", move_word(), { desc = "Move forward one word" })

	-- More emacs mappings:
	vim.keymap.set("i", "<C-d>", "<C-o>x", { desc = "Delete character in front of mark." })
	vim.keymap.set("i", "<M-H>", "<C-o><<", { desc = "Decrease indent." })
	vim.keymap.set("i", "<M-L>", "<C-o>>>", { desc = "Decrease indent." })
	vim.keymap.set("i", "", "<C-o>u", { desc = "Undo." })
	vim.keymap.set("i", "", "<C-o>d0", { desc = "Kill line backwards." })
	vim.keymap.set("i", "<M-BS>", "<C-o>db<C-o>i", { desc = "Kill word backwards." })

	-- Clear Currently Highlighted Regexp:
	vim.keymap.set(
		"n",
		"<leader>cr",
		':let<C-u>let @/=""<CR>',
		{ silent = true, noremap = true, desc = "Clear current regexp" }
	)

	-- Tab navigation:
	vim.keymap.set("n", "]t", "<cmd>tabnext<CR>", { silent = true, noremap = true, desc = "Jump to next tab" })
	vim.keymap.set("n", "[t", "<cmd>tabprev<CR>", { silent = true, noremap = true, desc = "Jump to previous tab" })

	-- Toggle Quickfix:
	vim.keymap.set("n", "<leader>q", function()
		require("neovim-config.functions").list_toggle("c")
	end, { silent = true, noremap = true, desc = "Display quickfix list" })
	vim.keymap.set("n", "<leader>d", function()
		require("neovim-config.functions").list_toggle("l")
	end, { silent = true, noremap = true, desc = "Display location list" })

	-- Project Grep:
	vim.keymap.set("n", "<leader>/", function()
		require("neovim-config.functions").grep_or_qfgrep()
	end, { silent = true, noremap = true, desc = "Search in current project using grep()" })

	-- Highlight a block and type "@" to run a macro on the block:
	vim.keymap.set("x", "@", function()
		vim.cmd([[echo '@'.getcmdline()
	execute ":'<,'>normal @".nr2char(getchar())]])
	end, { silent = true, noremap = true })

	-- Calculator:
	vim.keymap.set(
		"i",
		"<C-X><C-A>",
		"<C-O>yiW<End>=<C-R>=<C-R>0<CR>",
		{ silent = true, noremap = true, desc = "Calculate" }
	)

	-- Vertical split like in my Tmux config:
	vim.keymap.set("n", "<C-W>S", "<cmd>vsplit<cr>", { desc = "Split vertically" })

	vim.keymap.set("i", "<C-X><C-S>", "<c-o>:silent! w<cr>", { desc = "Save current buffer", silent = true })

	-- LazyGit:
	vim.keymap.set("n", "<leader>vg", "<cmd>LazyGit<cr>", { noremap = true, silent = true, desc = "Lazygit" })
end

return M
