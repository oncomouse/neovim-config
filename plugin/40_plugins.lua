-- ┌─────────────────────────┐
-- │ Plugins outside of MINI │
-- └─────────────────────────┘
--
-- This file contains installation and configuration of plugins outside of MINI.
-- They significantly improve user experience in a way not yet possible with MINI.
-- These are mostly plugins that provide programming language specific behavior.
--
-- Use this file to install and configure other such plugins.

-- Make concise helpers for installing/adding plugins in two stages
local add = vim.pack.add
local later, now = Config.later, Config.now
local now_if_args = Config.now_if_args
local now_if_headless = #vim.api.nvim_list_uis() == 0 and Config.now or Config.later

Config.use_ocaml = vim.fn.executable("opam") == 1 and vim.env.USER ~= "root"
-- Unified external tooling definition. Add a table with the ft of a treesitter
-- parser you'd like to use. Add lsps in <ft>.lsp table, using their lsp-config
-- name. Add tools you want mason to install using <ft>.mason as a table. You
-- can set type = "formatter"|"linter"|"dap" to tell the system which kind of
-- tool each is, so they are installed correctly.
Config.languages = {
	bash = {
		mason = { -- These are required for bash-lsp
			shellcheck = {},
			shfmt = {},
		},
	},
	css = {
		lsp = {
			"cssls",
			"biome",
		},
	},
	diff = {},
	fish = {
		lsp = {
			"fish_lsp",
		},
	},
	git_config = {},
	git_rebase = {},
	gitattributes = {},
	gitcommit = {},
	gitignore = {},
	html = {
		lsp = {
			"biome",
			"html",
		},
	},
	javascript = {},
	json = {},
	lua = {
		mason = {
			stylua = { type = "formatter" },
		},
		lsp = {
			"lua_ls",
		},
	},
	markdown = {},
	markdown_inline = {},
	ocaml = {
		lsp = {
			"ocamllsp",
		},
		mason = {
			ocamlformat = { type = "formatter" },
		},
	},
	python = {
		lsp = {
			"ruff",
		},
	},
	svelte = {
		lsp = {
			"svelte",
		},
	},
	typst = {
		lsp = {
			"tinymist",
		},
	},
	vimdoc = {},
}

-- Utility Packages ===========================================================

now(function()
	add({ "https://github.com/nvim-lua/plenary.nvim" })
end)

-- Tree-sitter ================================================================

-- Tree-sitter is a tool for fast incremental parsing. It converts text into
-- a hierarchical structure (called tree) that can be used to implement advanced
-- and/or more precise actions: syntax highlighting, textobjects, indent, etc.
--
-- Tree-sitter support is built into Neovim (see `:h treesitter`). However, it
-- requires two extra pieces that don't come with Neovim directly:
-- - Language parsers: programs that convert text into trees. Some are built-in
--   (like for Lua), 'nvim-treesitter' provides many others.
--   NOTE: It requires third party software to build and install parsers.
--   See the link for more info in "Requirements" section of the MiniMax README.
-- - Query files: definitions of how to extract information from trees in
--   a useful manner (see `:h treesitter-query`). 'nvim-treesitter' also provides
--   these, while 'nvim-treesitter-textobjects' provides the ones for Neovim
--   textobjects (see `:h text-objects`, `:h MiniAi.gen_spec.treesitter()`).
--
-- Add these plugins now if file (and not 'mini.starter') is shown after startup.
--
-- Troubleshooting:
-- - Run `:checkhealth vim.treesitter nvim-treesitter` to see potential issues.
-- - In case of errors related to queries for Neovim bundled parsers (like `lua`,
--   `vimdoc`, `markdown`, etc.), manually install them via 'nvim-treesitter'
--   with `:TSInstall <language>`. Be sure to have necessary system dependencies
--   (see MiniMax README section for software requirements).
now_if_args(function()
	local ts_update = function()
		vim.cmd("TSUpdate")
	end
	Config.on_packchanged("nvim-treesitter", { "update" }, ts_update, ":TSUpdate")
	add({
		"https://github.com/nvim-treesitter/nvim-treesitter",
		"https://github.com/nvim-treesitter/nvim-treesitter-textobjects",
		"https://github.com/RRethy/nvim-treesitter-endwise",
	})

	-- Define languages which will have parsers installed and auto enabled
	-- After changing this, restart Neovim once to install necessary parsers. Wait
	-- for the installation to finish before opening a file for added language(s).
	local languages = vim.tbl_keys(Config.languages)
	local isnt_installed = function(lang)
		return #vim.api.nvim_get_runtime_file("parser/" .. lang .. ".*", false) == 0
	end
	local to_install = vim.tbl_filter(isnt_installed, languages)
	if #to_install > 0 then
		require("nvim-treesitter").install(to_install)
	end

	-- Enable tree-sitter after opening a file for a target language
	local filetypes = {}
	for _, lang in ipairs(languages) do
		for _, ft in ipairs(vim.treesitter.language.get_filetypes(lang)) do
			table.insert(filetypes, ft)
		end
	end
	local ts_start = function(ev)
		-- vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
		vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
		vim.wo[0][0].foldmethod = "expr"
		vim.treesitter.start(ev.buf)
	end
	Config.new_autocmd("FileType", filetypes, ts_start, "Start tree-sitter")
end)

-- Language servers ===========================================================

-- Language Server Protocol (LSP) is a set of conventions that power creation of
-- language specific tools. It requires two parts:
-- - Server - program that performs language specific computations.
-- - Client - program that asks server for computations and shows results.
--
-- Here Neovim itself is a client (see `:h vim.lsp`). Language servers need to
-- be installed separately based on your OS, CLI tools, and preferences.
-- See note about 'mason.nvim' at the bottom of the file.
--
-- Neovim's team collects commonly used configurations for most language servers
-- inside 'neovim/nvim-lspconfig' plugin.
--
-- Add it now if file (and not 'mini.starter') is shown after startup.
now_if_args(function()
	add({ "https://github.com/neovim/nvim-lspconfig" })

	-- Use `:h vim.lsp.enable()` to automatically enable language server based on
	-- the rules provided by 'nvim-lspconfig'.
	-- Use `:h vim.lsp.config()` or 'after/lsp/' directory to configure servers.
	-- Uncomment and tweak the following `vim.lsp.enable()` call to enable servers.
	-- vim.lsp.enable(Config.enabled_lsps)
end)

-- Formatting =================================================================

-- Programs dedicated to text formatting (a.k.a. formatters) are very useful.
-- Neovim has built-in tools for text formatting (see `:h gq` and `:h 'formatprg'`).
-- They can be used to configure external programs, but it might become tedious.
--
-- The 'stevearc/conform.nvim' plugin is a good and maintained solution for easier
-- formatting setup.
now_if_args(function()
	add({ "https://github.com/stevearc/conform.nvim" })
	-- See also:
	-- - `:h Conform`
	-- - `:h conform-options`
	-- - `:h conform-formatters`

  -- Gather any formatters to be installed by mason:
	local formatters = {}
	for _, ft in pairs(vim.tbl_keys(Config.languages)) do
		if Config.languages[ft].mason then
			formatters[ft] = {}
			for _, tool in pairs(vim.tbl_keys(Config.languages[ft].mason)) do
				if Config.languages[ft].mason[tool].type == "formatter" then
					table.insert(formatters[ft], tool)
				end
			end
		end
	end

	require("conform").setup({
		default_format_opts = {
			-- Allow formatting from LSP server if no dedicated formatter is available
			lsp_format = "fallback",
		},
		formatters_by_ft = formatters,
	})
end)

-- Snippets ===================================================================

-- Although 'mini.snippets' provides functionality to manage snippet files, it
-- deliberately doesn't come with those.
--
-- The 'rafamadriz/friendly-snippets' is currently the largest collection of
-- snippet files. They are organized in 'snippets/' directory (mostly) per language.
-- 'mini.snippets' is designed to work with it as seamlessly as possible.
-- See `:h MiniSnippets.gen_loader.from_lang()`.
later(function()
	add({
		"https://github.com/rafamadriz/friendly-snippets",
		"https://github.com/abhinandh-s/typst-snippets",
	})
end)

-- Mason Configuration ========================================================

-- 'mason-org/mason.nvim' (a.k.a. "Mason") is a great tool (package manager) for
-- installing external language servers, formatters, and linters. It provides
-- a unified interface for installing, updating, and deleting such programs.
--
-- The caveat is that these programs will be set up to be mostly used inside Neovim.
-- If you need them to work elsewhere, consider using other package managers.
--
-- You can use it like so:
now_if_args(function()
	add({
		"https://github.com/mason-org/mason.nvim",
		"https://github.com/mason-org/mason-lspconfig.nvim",
	})

	require("mason").setup()
	require("mason-lspconfig").setup()

  -- Build datastructures we need to configure mason-lspconfig and install any other tools:
	Config.enabled_lsps = {}
	Config.mason_tools = {}
	for _, language in pairs(vim.tbl_keys(Config.languages)) do
		if Config.languages[language].lsp then
			for _, lsp in pairs(Config.languages[language].lsp) do
				table.insert(Config.enabled_lsps, lsp)
			end
		end
		if Config.languages[language].mason then
			for _, tool in pairs(vim.tbl_keys(Config.languages[language].mason)) do
				if Config.mason_tools[tool] then
					table.insert(Config.mason_tools[tool].filetypes, language)
				else
					Config.mason_tools[tool] = {
						filetypes = { language },
					}
				end
			end
		end
	end

	-- Use autocmds to install required LSPs:
	for _, lsp in pairs(Config.enabled_lsps) do
		local mappings = require("mason-lspconfig").get_mappings()
		if not vim.tbl_contains(require("mason-lspconfig").get_installed_servers(), lsp) then
			Config.new_autocmd("FileType", vim.lsp.config[lsp].filetypes, function(ev)
				if not vim.tbl_contains(require("mason-lspconfig").get_installed_servers(), lsp) then
					vim.cmd("MasonInstall " .. mappings["lspconfig_to_package"][lsp])
				end
			end)
		end
	end

	-- Use autocmds to install required tools:
	for _, tool in pairs(vim.tbl_keys(Config.mason_tools)) do
		if not require("mason-registry").is_installed(tool) then
			Config.new_autocmd("Filetype", Config.mason_tools[tool].filetypes, function(_)
				if not require("mason-registry").is_installed(tool) then
					vim.cmd("MasonInstall " .. tool)
				end
			end)
		end
	end
end)

-- Other Plugins ==========================================================

-- Load markdown helper:
vim.pack.add({ "https://github.com/oncomouse/markdown.nvim" })

-- Autonumber and manage lists in languages such as markdown (configured extensively in markdown)
vim.pack.add({ "https://github.com/gaoDean/autolist.nvim" })
require("autolist").setup({
	lists = {
		typst = {
			"[-+]", -- - + *
			"%d+[.)]+", -- 1. 2. 3.
			"%a[.)]+", -- a) b) c)
			"%u*[.)]+", -- I. II. III.
		},
	},
})

-- Emacs-style motions in Neovim
later(function()
	add({ "https://github.com/tpope/vim-rsi" })
end)

-- My preferred indent indicating plugin
later(function()
	add({ "https://github.com/lukas-reineke/indent-blankline.nvim" })
	require("ibl").setup({
		indent = {
			tab_char = "▏",
			char = "▏",
		},
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
end)

-- Magit emulation for Neovim
later(function()
	add({
		"https://github.com/sindrets/diffview.nvim",
		"https://github.com/NeogitOrg/neogit",
	})
end)

-- My preferred theme
now(function()
	add({
		{
			src = "https://github.com/catppuccin/nvim",
			name = "catppuccin",
		},
	})
	vim.cmd("colorscheme catppuccin-latte")
end)

later(function()
	vim.pack.add({ "https://github.com/oncomouse/nvim-ref" })
	require("nvim-ref").setup({
		bibfiles = {
			"~/Reading/library.bib",
		},
		include_pagenumbers = true,
		mappings = {
			{
				"i",
				"<C-c>@",
				"insert.citation",
			},
		},
	})
end)
