return {
			"echasnovski/mini.nvim",
			dependencies = {
				{ "oncomouse/mini-nvim-helpers" },
			},
			config = function()
				-- mini.basics
				require("mini.basics").setup({
					mappings = {
						move_with_alt = true,
						windows = true, -- Move <C-hjkl>; Resize <C-movearrows>
					},
				})
				vim.opt.completeopt:append("preview")
				vim.opt.shortmess:append("Wc")
				vim.opt.undofile = false

				local function make_point()
					local _, l, c, _ = unpack(vim.fn.getpos("."))
					return {
						line = l,
						col = c,
					}
				end
				require("mini.ai").setup({
					custom_textobjects = {
						g = function() -- Whole buffer
							local from = { line = 1, col = 1 }
							local last_line_length = #vim.fn.getline("$")
							local to = {
								line = vim.fn.line("$"),
								col = last_line_length == 0 and 1 or last_line_length,
							}
							return { from = from, to = to, vis_mode = "V" }
						end,

						z = function(type) -- Folds
							vim.api.nvim_feedkeys("[z" .. (type == "i" and "j0" or ""), "x", true)
							local from = make_point()
							vim.api.nvim_feedkeys("]z" .. (type == "i" and "k$" or "$"), "x", true)
							local to = make_point()

							return {
								from = from,
								to = to,
							}
						end,

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
				vim.keymap.set("n", "[t", "<cmd>tabprevious<cr>", {})
				vim.keymap.set("n", "]t", "<cmd>tabnext<cr>", {})
				vim.keymap.set("n", "[T", "<cmd>tabfirst<cr>", {})
				vim.keymap.set("n", "]T", "<cmd>tablast<cr>", {})

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
				require("mini.comment").setup({
					options = {
						custom_commentstring = function()
							return require("ts_context_commentstring").calculate_commentstring() or vim.bo.commentstring
						end,
					},
				})

				require("mini.extra").setup()

				-- nvim-colorizer configuration was:
				-- *: RGB, RRGGBB, RRGGBBAA, !names, !css
				-- !help, !lazy (off)
				-- html: names, !RRGGBBAA
				-- css: css, names, !RRGGBBAA
				-- scss/sass: css, names, !RRGGBBAA, sass
				-- TODO: css, sass, RRGGBBAA parsers
				-- TODO: disable parsers
				-- Hex Colors:
				require("mini.hipatterns").setup({
					highlighters = {
						short_hex_color = {
							pattern = "#%x%x%x%f[%X]",
							group = function(_, match)
								local r, g, b = match:sub(2, 2), match:sub(3, 3), match:sub(4, 4)
								local hex = string.format("#%s%s%s%s%s%s", r, r, g, g, b, b)
								return require("mini.hipatterns").compute_hex_color_group(hex, "bg")
							end,
						},
						hex_color = require("mini.hipatterns").gen_highlighter.hex_color(),
					},
				})
				require("mini.helpers").disable_mini_module("hipatterns", {
					filetypes = { "help", "lazy", "markdown", "text" },
					buftype = { "quickfix" },
					terminal = true,
				})
				-- HTML Words:-- Autogroups: {{{
				local augroup = vim.api.nvim_create_augroup("neovim-config-settings", { clear = true })
				-- }}}
				local names = vim.tbl_map(function(x)
					return string.lower(x)
				end, vim.tbl_keys(vim.api.nvim_get_color_map()))
				local cache = {}
				local function html_words(_, match)
					match = string.lower(match)
					if not vim.tbl_contains(names, match, {}) then
						return nil
					end
					if not cache[match] then
						cache[match] = "#" .. require("bit").tohex(vim.api.nvim_get_color_by_name(match), 6)
					end
					local color = cache[match]
					return require("mini.hipatterns").compute_hex_color_group(color, "bg")
				end
				-- Support short hex in
				require("mini.helpers").configure_mini_module("hipatterns", {
					highlighters = {
						word = { pattern = "%w+", group = html_words },
					},
				}, {
					filetype = { "css", "html", "sass", "scss" },
				})

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
					mappings = {
						object_scope = "ii",
						object_scope_with_border = "ai",
					},
				})
				require("mini.helpers").disable_mini_module("indentscope", {
					terminal = true,
					filetype = { "help", "alpha", "dashboard", "neo-tree", "Trouble", "lazy", "mason" },
					buftype = { "quickfix" },
				})

				require("mini.icons").setup({})
				MiniIcons.mock_nvim_web_devicons()

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

				-- use gS to split and join items in a list:
				require("mini.splitjoin").setup()

				-- Override function used to make statusline:
				require("mini.statusline").setup({})

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
			end,
		}
