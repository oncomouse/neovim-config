return {
	"nvimtools/none-ls.nvim",
	dependencies = {
		{ "williamboman/mason.nvim", config = true },
		"nvimtools/none-ls-extras.nvim",
		"jay-babu/mason-null-ls.nvim",
	},
	lazy = true,
	init = function()
		local sources = {}
		local augroup = vim.api.nvim_create_augroup("neovim-config-null-ls", {})
		local function add_source(mason_pkg, source_fn, ft)
			vim.api.nvim_create_autocmd("FileType", {
				pattern = type(ft) == "string" and ft or table.concat(ft, ","),
				group = augroup,
				once = true,
				callback = function()
					if require("neovim-config.utils.mason").mason_package_available(mason_pkg) then
						local opts = source_fn()
						for _, source in pairs(opts["_opts"] and { opts } or opts) do
							require("null-ls").register(source)
						end
					else
						require("neovim-config.utils.mason").missing_package(mason_pkg)
					end
				end,
			})
		end
		add_source("prettier", function()
			return {
				require("null-ls").builtins.formatting.prettier.with({
					update_on_insert = false,
					filetypes = {
						"css",
						"graphql",
						"handlebars",
						"html",
						"json",
						"jsonc",
						"less",
						"markdown",
						"markdown.mdx",
						"scss",
						"svelte",
						"typescript",
						"typescript.react",
						"vue",
					},
					extra_args = { "--use-tabs" },
					prefer_local = "node_modules/.bin",
				}),

				-- YAML
				require("null-ls").builtins.formatting.prettier.with({
					filetypes = {
						"yaml",
					},
					prefer_local = "node_modules/.bin",
				}),
			}
		end, {
			"css",
			"graphql",
			"handlebars",
			"html",
			"json",
			"jsonc",
			"less",
			"markdown",
			"markdown.mdx",
			"scss",
			"svelte",
			"typescript",
			"typescript.react",
			"vue",
			"yaml",
		})
		--LUA
		add_source("stylua", function()
			return require("null-ls").builtins.formatting.stylua
		end, "lua")
		add_source("selene", function()
			return require("null-ls").builtins.diagnostics.selene.with({
				cwd = function(_)
					return vim.fs.dirname(
						vim.fs.find({ "selene.toml" }, { upward = true, path = vim.api.nvim_buf_get_name(0) })[1]
					) or vim.fn.expand("~/.config/selene/") -- fallback value
				end,
			})
		end, "lua")

		-- FISH
		if vim.fn.executable("fish") == 1 then
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "fish",
				group = augroup,
				once = true,
				callback = function()
					require("null-ls").register(require("null-ls").builtins.formatting.fish_indent)
				end,
			})
		end

		-- SHELL
		add_source("shfmt", function()
			return require("null-ls").builtins.formatting.shfmt
		end, "sh")

		-- VIML
		add_source("vint", function()
			return require("null-ls").builtins.diagnostics.vint
		end, "vim")

		-- HTML
		add_source("markuplint", function()
			return require("null-ls").builtins.diagnostics.markuplint
		end, "html")

		-- JAVASCRIPT
		add_source("standardjs", function()
			return require("null-ls.builtins.formatting.standardjs")
		end, {
			"javascript",
			"javascript.react",
			"typescript",
			"typescript.react",
		})

		add_source("standardjs", function()
			return require("null-ls.builtins.diagnostics.standardjs")
		end, {
			"javascript",
			"javascript.react",
			"typescript",
			"typescript.react",
		})

		return {
			sources = sources,
		}
	end,
}
