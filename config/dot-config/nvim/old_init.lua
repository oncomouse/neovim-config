-- Set Leader:
vim.g.mapleader = " "
vim.g.maplocalleader = ","

local Dotfiles = {}

-- ==============================================================================
-- Basic Settings
-- ==============================================================================
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

-- Enable termguicolors by default
vim.opt.termguicolors = true

-- Tabs
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = false

-- ==============================================================================
-- Disable Plugins
-- ==============================================================================
vim.g.loaded_gzip = true
vim.g.loaded_tarPlugin = true
vim.g.loaded_zipPlugin = true
vim.g.loaded_2html_plugin = true
vim.g.loaded_rrhelper = true
vim.g.loaded_remote_plugins = true

-- ==============================================================================
-- Autocommands
-- ==============================================================================
local augroup = vim.api.nvim_create_augroup("neovim-config-settings", { clear = true })
-- Turn Off Line Numbering:
vim.api.nvim_create_autocmd("TermOpen", { group = augroup, command = "setlocal nonumber norelativenumber" })

-- Start QuickFix:
vim.api.nvim_create_autocmd("QuickFixCmdPost", {
	group = augroup,
	pattern = "[^l]*",
	callback = function()
		Dotfiles.list_toggle("c", 1)
	end,
})
vim.api.nvim_create_autocmd("QuickFixCmdPost", {
	group = augroup,
	pattern = "l*",
	callback = function()
		Dotfiles.list_toggle("c", 1)
	end,
})

-- Close Preview Window:
vim.api.nvim_create_autocmd("CompleteDone", {
	group = augroup,
	callback = function()
		if vim.fn.pumvisible() == 0 then
			vim.cmd("pclose")
		end
	end,
})
-- ==============================================================================
-- Basic Maps
-- ==============================================================================
-- Linewise Navigation
vim.keymap.set("n", "j", "(v:count == 0 ? 'gj' : 'j')", { expr = true, silent = true })
vim.keymap.set("n", "k", "(v:count == 0 ? 'gk' : 'k')", { expr = true, silent = true })

-- Toggle Quickfix:
vim.keymap.set("n", "<leader>lq", function()
	Dotfiles.list_toggle("c")
end, { silent = true, noremap = true, desc = "Display quickfix list" })
vim.keymap.set("n", "<leader>ld", function()
	Dotfiles.list_toggle("l")
end, { silent = true, noremap = true, desc = "Display location list" })

-- Project Grep:
vim.keymap.set("n", "<leader>sp", function()
	Dotfiles.grep_or_qfgrep()
end, { silent = true, noremap = true, desc = "Search in current project using grep()" })

-- Highlight a block and type "@" to run a macro on the block:
vim.keymap.set("x", "@", function()
	vim.cmd([[echo '@'.getcmdline()
execute ":'<,'>normal @".nr2char(getchar())]])
end, { silent = true, noremap = true })

-- ==============================================================================
-- Commands
-- ==============================================================================
-- Adjust Spacing:
vim.api.nvim_create_user_command("Spaces", function(args)
	local wv = vim.fn.winsaveview()
	vim.opt_local.expandtab = true
	vim.opt_local.tabstop = tonumber(args.args)
	vim.opt_local.softtabstop = tonumber(args.args)
	vim.opt_local.shiftwidth = tonumber(args.args)
	vim.cmd("silent execute '%!expand -it" .. args.args .. "'")
	vim.fn.winrestview(wv)
	vim.cmd("setlocal ts? sw? sts? et?")
end, {
	force = true,
	nargs = 1,
})
vim.api.nvim_create_user_command("Tabs", function(args)
	local wv = vim.fn.winsaveview()
	vim.opt_local.expandtab = false
	vim.opt_local.tabstop = tonumber(args.args)
	vim.opt_local.softtabstop = tonumber(args.args)
	vim.opt_local.shiftwidth = tonumber(args.args)
	vim.cmd("silent execute '%!unexpand -t" .. args.args .. "'")
	vim.fn.winrestview(wv)
	vim.cmd("setlocal ts? sw? sts? et?")
end, {
	force = true,
	nargs = 1,
})

vim.api.nvim_create_user_command("Mf", function(args)
	local file = vim.uv.fs_realpath(args.args) or args.args
	vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
	vim.cmd("e " .. file)
end, {
	desc = "Implement the functionality of mf: if directory does not exist for new file create it before creating the file.",
	complete = "dir",
	nargs = 1,
})
-- ==============================================================================
-- Functions
-- ==============================================================================
-- Open or close quickfix or loclist
function Dotfiles.list_toggle(pfx, force_open)
	local status
	if pfx == "c" then
		status = vim.fn.getqflist({ winid = 0 }).winid ~= 0
	else
		status = vim.fn.getloclist(0, { winid = 0 }).winid ~= 0
	end
	if not force_open then
		if status then
			vim.cmd(pfx .. "close")
			return
		end
		if pfx == "l" and #vim.fn.getloclist(0) == 0 then
			vim.cmd([[echohl ErrorMsg
		echo 'Location List is Empty.'
		echohl NONE]])
			return
		end
	end
	vim.cmd(pfx .. "open")
end

-- Run grep! unless we're in quickfix results, then run cfilter
function Dotfiles.grep_or_qfgrep()
	if vim.opt.buftype:get() == "quickfix" then
		-- Load cfilter in quickfix view:
		vim.cmd([[packadd cfilter]])
		local input = vim.fn.input("QFGrep/")
		if #input > 0 then
			local prefix = vim.fn.getwininfo(vim.fn.win_getid())[1].loclist == 1 and "L" or "C"
			vim.cmd(prefix .. "filter /" .. input .. "/")
		end
	else
		local input = vim.fn.input("Grep/")
		if #input > 0 then
			vim.cmd('silent! grep! "' .. input .. '"')
		end
	end
end

-- ==============================================================================
-- LSP
-- ==============================================================================
local on_lsp_attach = function(client, bufnr)
    local lsp_map = function(keys, func, desc)
        if desc then
            desc = "LSP: " .. desc
        end

        vim.keymap.set("n", keys, func, { remap = true, buffer = bufnr, desc = desc, silent = true })
    end

    lsp_map("gH", function()
                         if client.name == "rust-analyzer" then
                             vim.cmd.RustLsp { "hover", "actions" }
                         else
                             vim.lsp.buf.hover()
                         end
                     end, "Hover Documentation")
    lsp_map("<C-r>", vim.lsp.buf.rename, "Rename")
    lsp_map("gD", vim.lsp.buf.definition, "Goto Declaration")
    lsp_map("gi", vim.lsp.buf.implementation, "Goto Implementation")
    lsp_map("gd", "<C-]>", "[G]oto [D]efinition")
    lsp_map("gu", vim.lsp.buf.signature_help, "Signature Documentation")

    -- Various picker for lsp related stuff
    lsp_map("fr", '<Cmd>Pick lsp scope="references"<CR>', "[G]oto [R]eferences")
    lsp_map("fi", '<Cmd>Pick lsp scope="implementation"<CR>', "[G]oto [I]mplementations")
    lsp_map("ft", '<Cmd>Pick lsp scope="type_definition"<CR>', "[G]oto [I]mplementations")
    lsp_map("fw", '<Cmd>Pick lsp scope="workspace_symbol"<CR>', "Search workspace symbols")

    lsp_map("<leader>lr", function()
                              vim.cmd "LspRestart"
                          end, "Lsp [R]eload")
    lsp_map("<leader>li", function()
                              vim.cmd "LspInfo"
                          end, "Lsp [R]eload")
    lsp_map("<leader>lh", function()
                              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled(filter), { bufnr })
                          end, "Lsp toggle inlay [h]ints")
end

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
-- optimizes cpu usage source https://github.com/neovim/neovim/issues/23291
capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = false

vim.diagnostic.config {
    virtual_text = true,
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = "󰚌 ",
            [vim.diagnostic.severity.WARN] = " ",
            [vim.diagnostic.severity.INFO] = " ",
            [vim.diagnostic.severity.HINT] = "󱧡 ",
        },
        numhl = {
            [vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
            [vim.diagnostic.severity.WARN] = "DiagnosticSignWarn",
            [vim.diagnostic.severity.INFO] = "DiagnosticSignInfo",
            [vim.diagnostic.severity.HINT] = "DiagnosticSignHint",
        },
        texthl = {
            [vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
            [vim.diagnostic.severity.WARN] = "DiagnosticSignWarn",
            [vim.diagnostic.severity.INFO] = "DiagnosticSignInfo",
            [vim.diagnostic.severity.HINT] = "DiagnosticSignHint",
        },
    },
}

local border = {
    { "╭", "FloatBorder" },
    { "─", "FloatBorder" },
    { "╮", "FloatBorder" },
    { "│", "FloatBorder" },
    { "╯", "FloatBorder" },
    { "─", "FloatBorder" },
    { "╰", "FloatBorder" },
    { "│", "FloatBorder" },
}

local handlers = {
    ["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
        border = border,
    }),
    ["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
        border = border,
    }),
}

-- Your existing floating preview override
local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
    opts = opts or {}
    opts.border = opts.border or border
    return orig_util_open_floating_preview(contents, syntax, opts, ...)
end

-- Set up global defaults first
vim.lsp.config("*", {
    capabilities = capabilities,
    on_attach = on_lsp_attach,
    handlers = handlers,
    root_markers = { ".git" },
})

vim.lsp.config["lua_ls"] = {
    cmd = { "lua-language-server" },
    single_file_support = false,
    filetypes = { "lua" },
    root_markers = { ".git", ".git/" },
    settings = {
        Lua = {
            runtime = {
                version = "LuaJIT",
            },
            diagnostics = {
                globals = { "vim" },
            },
            workspace = {
                checkThirdParty = false,
                library = rt,
            },
        },
    },
}

vim.lsp.config["ocamllsp"] = {
    cmd = { "ocamllsp" },
    filetypes = { "ocaml", "dune" },
    root_markers = { "package.json", ".git", "dune-project" },
}

vim.lsp.enable({
    "ocamllsp",
    "lua_ls",
})

-- ==============================================================================
-- Plugins
-- ==============================================================================

-- Clone 'mini.nvim' manually in a way that it gets managed by 'mini.deps'

local path_package = vim.fn.stdpath('data') .. '/site/'
local mini_path = path_package .. 'pack/deps/start/mini.nvim'
if not vim.loop.fs_stat(mini_path) then
    vim.cmd('echo "Installing `mini.nvim`" | redraw')
    local clone_cmd = {
        'git', 'clone', '--filter=blob:none',
        'https://github.com/nvim-mini/mini.nvim', mini_path
    }
    vim.fn.system(clone_cmd)
    vim.cmd('packadd mini.nvim | helptags ALL')
    vim.cmd('echo "Installed `mini.nvim`" | redraw')
end

-- Set up 'mini.deps' (customize to your liking)
require('mini.deps').setup({ path = { package = path_package } })

MiniDeps.add({ source = "oncomouse/mini-nvim-helpers" })
MiniDeps.add({ source = "tpope/vim-rsi" })
MiniDeps.add({ source = "tpope/vim-sleuth" })
MiniDeps.add({ source = "lukas-reineke/indent-blankline.nvim" })

require("ibl").setup({
	indent = { char = "▏" },
	scope = { enabled = false },
	exclude = {
		filetypes = {
			"help",
			"alpha",
			"dashboard",
			"neo-tree",
			"Trouble",
			"lazy",
			"mason",
			"notify",
			"toggleterm",
			"lazyterm",
		},
	},
})

require("mini.basics").setup({
	mappings = {
		move_with_alt = true,
		windows = true, -- Move <C-hjkl>; Resize <C-movearrows>
	},
})
vim.opt.completeopt:append("preview")
vim.opt.shortmess:append("Wc")
vim.opt.undofile = false

require("mini.ai").setup({
	custom_textobjects = {
		g = require('mini.extra').gen_ai_spec.buffer(),
		i = require('mini.extra').gen_ai_spec.indent(),
		l = require('mini.extra').gen_ai_spec.line(),
		n = require('mini.extra').gen_ai_spec.number(),

		[","] = { -- Grammatically correct comma matching
			{
				"[%.?!][ ]*()()[^,%.?!]+(),[ ]*()", -- Start of sentence
				"(),[ ]*()[^,%.?!]+()()[%.?!][ ]*", -- End of sentence
				",[ ]*()[^,%.?!]+(),[ ]*", -- Dependent clause
				"^()[A-Z][^,%.?!]+(),[ ]*", -- Start of line
			},
		},
	},
	mappings = {
		around_last = "aN",
		inside_last = "iN",
	},
	n_lines = 50,
	search_method = "cover", -- Only use next and last mappings to search
})

local spec_pair = require("mini.ai").gen_spec.pair
require("mini.helpers").configure_mini_module("ai", {
	custom_textobjects = {
		["*"] = spec_pair("*", "*", { type = "greedy" }), -- Grab all asterisks when selecting
		["_"] = spec_pair("_", "_", { type = "greedy" }), -- Grab all underscores when selecting
		["l"] = { "%b[]%b()", "^%[().-()%]%([^)]+%)$" }, -- Link targeting name
		["L"] = { "%b[]%b()", "^%[.-%]%(()[^)]+()%)$" }, -- Link targeting href
	},
}, {
	filetype = "markdown",
})
require("mini.helpers").configure_mini_module("ai", {
	custom_textobjects = {
		["s"] = spec_pair("[[", "]]"),
	},
}, {
	filetype = "lua",
})

-- ga/gA for align:
require("mini.align").setup({})

-- Paired commands such as [q/]q
require("mini.bracketed").setup({})
vim.keymap.set("n", "]t", "<cmd>tabnext<CR>", { silent = true, noremap = true, desc = "Jump to next tab" })
vim.keymap.set("n", "[t", "<cmd>tabprev<CR>", { silent = true, noremap = true, desc = "Jump to previous tab" })
vim.keymap.set("n", "[T", "<cmd>tabfirst<cr>", { silent = true, noremap = true, desc = "Jump to first tab" })
vim.keymap.set("n", "]T", "<cmd>tablast<cr>", { silent = true, noremap = true, desc = "Jump to last tab" })

-- :Bd[!] for layout-safe bufdelete
require("mini.bufremove").setup()
vim.api.nvim_create_user_command("Bd", function(args)
	MiniBufremove.delete(0, not args.bang)
end, {
	bang = true,
})

-- Use mini.clue for assisting with keybindings:
require("mini.clue").setup({
	window = {
		config = function()
			return {
				anchor = "SW",
				width = math.floor(0.618 * vim.o.columns),
				row = "auto",
				col = "auto",
			}
		end,
	},
	triggers = {
		-- Leader triggers
		{ mode = "n", keys = "<Leader>" },
		{ mode = "x", keys = "<Leader>" },

		-- Built-in completion
		{ mode = "i", keys = "<C-x>" },

		-- `g` key
		{ mode = "n", keys = "g" },
		{ mode = "x", keys = "g" },

		-- Marks
		{ mode = "n", keys = "'" },
		{ mode = "n", keys = "`" },
		{ mode = "x", keys = "'" },
		{ mode = "x", keys = "`" },

		-- Registers
		{ mode = "n", keys = '"' },
		{ mode = "x", keys = '"' },
		{ mode = "i", keys = "<C-r>" },
		{ mode = "c", keys = "<C-r>" },

		-- Window commands
		{ mode = "n", keys = "<C-w>" },

		-- `z` key
		{ mode = "n", keys = "z" },
		{ mode = "x", keys = "z" },
	},
	clues = {
		-- Enhance this by adding descriptions for <Leader> mapping groups
		require("mini.clue").gen_clues.builtin_completion(),
		require("mini.clue").gen_clues.g(),
		require("mini.clue").gen_clues.marks(),
		require("mini.clue").gen_clues.registers(),
		require("mini.clue").gen_clues.windows(),
		require("mini.clue").gen_clues.z(),
	},
})

-- gc for Comments
require("mini.comment").setup()

require("mini.completion").setup({
	mappings = {
		scroll_down = "",
		scroll_up = "",
	}
})

require("mini.extra").setup()

-- Show current indentation context:
require("mini.indentscope").setup({
	symbol = "▏",
	options = {
		indent_at_cursor = false,
		try_as_border = true,
	},
	draw = {
		animation = require("mini.indentscope").gen_animation.none(),
	},
})
require("mini.helpers").disable_mini_module("indentscope", {
	terminal = true,
	filetype = { "help", "alpha", "dashboard", "neo-tree", "Trouble", "lazy", "mason" },
	buftype = { "quickfix" },
})

require("mini.jump2d").setup({
	labels = "asdfjklghqweruiopzxvcvnmtyvb",
})
vim.keymap.set("n", "gG", function() MiniJump2d.start(MiniJump2d.builtin_opts.query) end, { noremap = true, desc = "Jump to queried string" })
vim.keymap.set("n", "gl", function() MiniJump2d.start(vim.tbl_extend("keep", MiniJump2d.builtin_opts.line_start, {
	view = { n_steps_ahead = 999 }
})) end, { noremap = true, desc = "Jump to line" })

-- Move lines with alt + hjkl:
require("mini.move").setup()

require("mini.misc").setup()
require("mini.misc").setup_auto_root({
	".git",
	"Gemfile",
	"Makefile",
	"Rakefile",
	"package.json",
	"pyproject.toml",
	"setup.py",
	".project-root",
})
require("mini.misc").setup_restore_cursor()

require("mini.notify").setup()
vim.keymap.set("n", "<leader>nn", MiniNotify.show_history, { desc = "Help Tags" })

-- Useful text operators
-- g= for calcuation; gx for exchanging regions (use twice to select and replace); gm multiply; gr for replace with register; gs for sorting
require("mini.operators").setup()

-- Autopairing:
require("mini.pairs").setup()

require("mini.pick").setup()
vim.keymap.set("n", "<leader>sb", function() MiniPick.builtin.buffers({}, { mappings = {
	wipeout = {
		char = "<C-d>",
		func = function()
			vim.api.nvim_buf_delete(MiniPick.get_picker_matches().current.bufnr, {})
		end
	}
}}) end, { desc = "Select a buffer" })
vim.ui.select = MiniPick.ui_select
vim.keymap.set("n", "<leader>sf", MiniPick.builtin.files, { desc = "Select a file from the current project" })
vim.keymap.set("n", "<leader>sh", MiniPick.builtin.help, { desc = "Select a help article" })

-- use gS to split and join items in a list:
require("mini.splitjoin").setup()

-- Use cs/ys/ds to manipulate surrounding delimiters:
require("mini.surround").setup({
	custom_surroundings = {
		["q"] = {
			input = {
				{ "“().-()”", "‘().-()’" },
				{ "“().-()”", "‘().-()’" },
			},
			output = { left = "“", right = "”" },
		},

		["Q"] = {
			input = { "‘().-()’" },
			output = { left = "‘", right = "’" },
		},
	},
	mappings = {
		add = "ys",
		delete = "ds",
		find = "sf",
		find_left = "sF",
		highlight = "sh",
		replace = "cs",
		update_n_lines = "",
		suffix_last = "N",
		suffix_next = "n",
	},
	n_lines = 50,
	search_method = "cover_or_next",
})
-- Remap adding surrounding to Visual mode selection
vim.keymap.set("x", "S", [[:<C-u>lua MiniSurround.add('visual')<CR>]], { noremap = true })
-- Make special mapping for "add surrounding for line"
vim.keymap.set("n", "yss", "ys_", { noremap = false })
require("mini.helpers").configure_mini_module("surround", {
	custom_surroundings = {
		["B"] = { -- Surround for bold
			input = { "%*%*().-()%*%*" },
			output = { left = "**", right = "**" },
		},
		["I"] = { -- Surround for italics
			input = { "%*().-()%*" },
			output = { left = "*", right = "*" },
		},
		["L"] = {
			input = { "%[().-()%]%([^)]+%)" },
			output = function()
				local href = require("mini.surround").user_input("Href")
				return {
					left = "[",
					right = "](" .. href .. ")",
				}
			end,
		},
	},
}, {
	filetype = "markdown",
})
require("mini.helpers").configure_mini_module("surround", {
	custom_surroundings = {
		s = {
			input = { "%[%[().-()%]%]" },
			output = { left = "[[", right = "]]" },
		},
	},
}, {
	filetype = "lua",
})
require("mini.helpers").configure_mini_module("surround", {
	custom_surroundings = {
		l = {
			input = { "%[%[().-()%]%]" },
			output = { left = "[[", right = "]]" },
		},
	},
}, {
	filetype = "org",
})
require("mini.tabline").setup({
	set_vim_settings = false,
	tabpage_section = "none",
})

require("mini.trailspace").setup()
vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
	callback = function()
		MiniTrailspace.trim()
		MiniTrailspace.trim_last_lines()
	end,
})
