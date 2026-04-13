-- ┌─────────────────────────┐
-- │ Filetype config example │
-- └─────────────────────────┘
--
-- This is an example of a configuration that will apply only to a particular
-- filetype, which is the same as file's basename ('markdown' in this example;
-- which is for '*.md' files).
--
-- It can contain any code which will be usually executed when the file is opened
-- (strictly speaking, on every 'filetype' option value change to target value).
-- Usually it needs to define buffer/window local options and variables.
-- So instead of `vim.o` to set options, use `vim.bo` for buffer-local options and
-- `vim.cmd('setlocal ...')` for window-local options (currently more robust).
--
-- This is also a good place to set buffer-local 'mini.nvim' variables.
-- See `:h mini.nvim-buffer-local-config` and `:h mini.nvim-disabling-recipes`.

-- Enable spelling and wrap for window
vim.cmd("setlocal spell wrap")

-- Disable built-in `gO` mapping in favor of 'mini.basics'
vim.keymap.del("n", "gO", { buffer = 0 })

-- Set markdown-specific ai objects in 'mini.ai'
local spec_pair = require("mini.ai").gen_spec.pair
vim.b.miniai_config = {
	custom_textobjects = {
		["*"] = spec_pair("*", "*", { type = "greedy" }), -- Grab all asterisks when selecting
		["_"] = spec_pair("_", "_", { type = "greedy" }), -- Grab all underscores when selecting
		["`"] = spec_pair("`", "`", { type = "greedy" }), -- Grab all underscores when selecting
		["l"] = { "%b[]%b()", "^%[().-()%]%([^)]+%)$" }, -- Link targeting name
		["L"] = { "%b[]%b()", "^%[.-%]%(()[^)]+()%)$" }, -- Link targeting href
	},
}
vim.b.minisurround_config = {
	custom_surroundings = {
		b = { -- Surround for bold
			input = { "%*%*().-()%*%*" },
			output = { left = "**", right = "**" },
		},
		i = { -- Surround for italics
			input = { "%_().-()%_" },
			output = { left = "*", right = "*" },
		},
		L = {
			input = { "%[().-()%]%(.-%)" },
			output = function()
				local link = require("mini.surround").user_input("Link: ")
				return { left = "[", right = "](" .. link .. ")" }
			end,
		},
	},
}

require("mini.pairs").map_buf(0, "i", "*", { action = "closeopen", pair = "**" })
require("mini.pairs").map_buf(0, "i", "_", { action = "closeopen", pair = "__" })
