local M = {}

function M.setup()
	-- Basic Settings
	-- Don't redraw between macro runs (may make terminal flicker)
	vim.opt.lazyredraw = true

	-- Line Numbering:
	vim.opt.relativenumber = true

	-- Folds:
	vim.opt.foldlevel = 99
	vim.opt.foldmethod = "indent"

	-- Use split for search/replace preview:
	vim.opt.inccommand = "split"

	-- Height Of The Preview Window:
	vim.opt.previewheight = 14

	-- <C-z> expands wildcards in command mode
	vim.opt.wildcharm = vim.api.nvim_replace_termcodes("<C-z>", true, true, true):byte()
	-- stuff to ignore when tab completing:
	vim.opt.wildignore = {
		"*.o,*.obj,*~",
		"*vim/backups*",
		"*sass-cache*",
		"*DS_Store*",
		"vendor/rails/**",
		"vendor/cache/**",
		"node_modules/**",
		"*.gem",
		"log/**",
		"tmp/**",
		"*.png,*.jpg,*.gif",
	}

	-- Set path to current file direction and pwd:
	vim.opt.path = ".,,"

	-- Use better grep, if available:
	if vim.fn.executable("rg") == 1 then
		vim.opt.grepprg = "rg --vimgrep --smart-case"
		vim.opt.grepformat = "%f:%l:%c:%m"
	elseif vim.fn.executable("ag") == 1 then
		vim.opt.grepprg = "ag --vimgrep"
		vim.opt.grepformat = "%f:%l:%c:%m"
	else
		vim.opt.grepprg = "grep -rn"
	end

	-- Linewrap:
	vim.opt.wrap = true
	vim.opt.showbreak = "↳ " -- Show a line has wrapped

	vim.opt.dictionary = "/usr/share/dict/words"

	-- Minimal Statusbar:
	vim.opt.statusline = " %0.45f%m%h%w%r%= %y %l:%c "

	-- Clipboard:
	if vim.fn.has("clipboard") == 1 then
		vim.opt.clipboard = { "unnamed" }
		if vim.fn.has("unnamedplus") == 1 then
			vim.opt.clipboard:prepend("unnamedplus")
		end
	end

	-- Cmdheight=0 options:
	vim.opt.cmdheight = 1
	if vim.opt.cmdheight == 0 then
		vim.opt.showcmdloc = "statusline"
	end
	vim.opt.showmode = false

	-- Enable termguicolors by default
	vim.opt.termguicolors = true

	-- Tabs
	vim.opt.tabstop = 4
	vim.opt.shiftwidth = 4
	vim.opt.softtabstop = 4
	vim.opt.expandtab = false
end

return M
