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
local add, later = MiniDeps.add, MiniDeps.later
local now_if_args = _G.Config.now_if_args

_G.Config.use_ocaml = vim.fn.executable("opam") == 1
_G.Config.enabled_lsps = {
	"fish_lsp",
	"lua_ls",
	"bashls",
	"html",
	"cssls",
	"jsonls",
	"ts_ls",
	"eslint",
}
if _G.Config.use_ocaml then
	table.insert(_G.Config.enabled_lsps, "ocamllsp")
end

-- Utility Packages ===========================================================

MiniDeps.now(function()
	add("nvim-lua/plenary.nvim")
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
	add({
		source = "nvim-treesitter/nvim-treesitter",
		-- Update tree-sitter parser after plugin is updated
		hooks = {
			post_checkout = function()
				vim.cmd("TSUpdate")
			end,
		},
	})
	add({
		source = "nvim-treesitter/nvim-treesitter-textobjects",
		-- Use `main` branch since `master` branch is frozen, yet still default
		-- It is needed for compatibility with 'nvim-treesitter' `main` branch
		checkout = "main",
	})

	-- Define languages which will have parsers installed and auto enabled
	-- After changing this, restart Neovim once to install necessary parsers. Wait
	-- for the installation to finish before opening a file for added language(s).
	local languages = {
		"javascript",
		"bash",
		"css",
		"fish",
		"json",
		"html",
		"ocaml",
		"lua",
		"vimdoc",
		"markdown",
		-- Add here more languages with which you want to use tree-sitter
		-- To see available languages:
		-- - Execute `:=require('nvim-treesitter').get_available()`
		-- - Visit 'SUPPORTED_LANGUAGES.md' file at
		--   https://github.com/nvim-treesitter/nvim-treesitter/blob/main
	}
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
		vim.treesitter.start(ev.buf)
	end
	_G.Config.new_autocmd("FileType", filetypes, ts_start, "Start tree-sitter")
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
	add("neovim/nvim-lspconfig")

	-- Use `:h vim.lsp.enable()` to automatically enable language server based on
	-- the rules provided by 'nvim-lspconfig'.
	-- Use `:h vim.lsp.config()` or 'after/lsp/' directory to configure servers.
	-- Uncomment and tweak the following `vim.lsp.enable()` call to enable servers.
	vim.lsp.enable(_G.Config.enabled_lsps)
end)

-- Formatting =================================================================

-- Programs dedicated to text formatting (a.k.a. formatters) are very useful.
-- Neovim has built-in tools for text formatting (see `:h gq` and `:h 'formatprg'`).
-- They can be used to configure external programs, but it might become tedious.
--
-- The 'stevearc/conform.nvim' plugin is a good and maintained solution for easier
-- formatting setup.
now_if_args(function()
	add("stevearc/conform.nvim")
	-- See also:
	-- - `:h Conform`
	-- - `:h conform-options`
	-- - `:h conform-formatters`
	require("conform").setup({
		default_format_opts = {
			-- Allow formatting from LSP server if no dedicated formatter is available
			lsp_format = "fallback",
		},
		-- Map of filetype to formatters
		-- Make sure that necessary CLI tool is available
		formatters_by_ft = {
			ocaml = { _G.Config.use_ocaml and "ocamlformat" or nil },
			lua = { "stylua" },
			javascript = { "prettierd" },
			typescript = { "prettierd" },
			html = { "prettierd" },
			css = { "prettierd" },
			json = { "prettierd" },
		},
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
	add("rafamadriz/friendly-snippets")
end)

-- oncomouse plugins ==========================================================

-- Emacs-style motions in Neovim
later(function()
	add("tpope/vim-rsi")
end)

-- My preferred indent indicating plugin
later(function()
	add({ source = "lukas-reineke/indent-blankline.nvim" })
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

-- Emacs-style kill-ring support
later(function()
	add("gbprod/yanky.nvim")
	require("yanky").setup()
end)

-- Magit emulation for Neovim
later(function()
	add("sindrets/diffview.nvim")
	add("NeogitOrg/neogit")
end)

-- My preferred theme
MiniDeps.now(function()
	add("catppuccin/nvim")
	vim.cmd("colorscheme catppuccin")
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
	local ensure_installed = {
		"shellcheck", -- bashls dependecy
		"shfmt", -- bashls dependecy
	}

	add("mason-org/mason.nvim")
	add("mason-org/mason-lspconfig.nvim")
	add("LittleEndianRoot/mason-conform")
	add("WhoIsSethDaniel/mason-tool-installer.nvim")
	require("mason").setup()
	require("mason-lspconfig").setup()
	-- Use autocmds to install required LSPs:
	local installed_servers = require("mason-lspconfig").get_installed_servers()
	for _, lsp in pairs(_G.Config.enabled_lsps) do
		if not vim.tbl_contains(installed_servers, lsp) then
			local mappings = require("mason-lspconfig").get_mappings()
			_G.Config.new_autocmd("FileType", vim.lsp.config[lsp].filetype, function(ev)
				vim.cmd("MasonInstall " .. mappings["lspconfig_to_package"][lsp])
			end)
		end
	end
	require("mason-conform").setup({
		quiet_mode = true,
	})
	require("mason-tool-installer").setup({
		ensure_installed = ensure_installed,
	})
end)
