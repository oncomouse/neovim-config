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

-- Set markdown-specific ai objects in 'mini.ai'
local spec_pair = require("mini.ai").gen_spec.pair
vim.b.miniai_config = {
	custom_textobjects = {
		["*"] = spec_pair("*", "*", { type = "greedy" }),
		["_"] = spec_pair("_", "_", { type = "greedy" }),
		["m"] = spec_pair("$", "$", { type = "greedy" }),
		["`"] = spec_pair("`", "`", { type = "greedy" }),
	},
}

-- Set markdown-specific surrounding in 'mini.surround'
vim.b.minisurround_config = {
	custom_surroundings = {
		m = {
			input = { "%$().-()%$" },
			output = { left = "$", right = "$" },
		},
		M = {
			input = { "%$().-()%$" },
			output = { left = "$ ", right = " $" },
		},
		L = {
			input = { "%(.-%)%[().-()%]" },
			output = function()
				local link = require("mini.surround").user_input("Link: ")
				return { left = '#link("' .. link .. '")[', right = "]" }
			end,
		},
	},
}

require("mini.keymap").map_multistep("i", "+", {
	{
		condition = function()
			local current_line = vim.api.nvim_get_current_line()
			local cursor_pos = vim.api.nvim_win_get_cursor(0)
			return string.match(current_line:sub(1, cursor_pos[2]), "^%s*$")
		end,
		action = function()
			return "+ "
		end,
	},
	{
		condition = function()
			return true
		end,
		action = function()
			return "+"
		end,
	},
}, {
	buf = 0,
})
require("mini.keymap").map_multistep("i", "-", {
	{
		condition = function()
			local current_line = vim.api.nvim_get_current_line()
			local cursor_pos = vim.api.nvim_win_get_cursor(0)
			return string.match(current_line:sub(1, cursor_pos[2]), "^%s*$")
		end,
		action = function()
			return "- "
		end,
	},
	{
		condition = function()
			return true
		end,
		action = function()
			return "-"
		end,
	},
}, {
	buf = 0,
})

require("mini.pairs").map_buf(0, "i", "$", { action = "closeopen", pair = "$$" })
require("mini.pairs").map_buf(0, "i", "_", { action = "closeopen", pair = "__" })
require("mini.pairs").map_buf(0, "i", "*", { action = "closeopen", pair = "**" })
require("mini.pairs").map_buf(0, "i", "`", { action = "closeopen", pair = "``" })

-- Autolist ==========================================================
-- Default autolist maps:
vim.keymap.set("n", "o", "o<CMD>AutolistNewBullet<CR>", { buf = 0 })
vim.keymap.set("n", "O", "O<CMD>AutolistNewBulletBefore<CR>", { buf = 0 })
vim.keymap.set("n", "<CR>", "<CMD>AutolistToggleCheckbox<CR><CR>", { buf = 0 })
vim.keymap.set("n", "<C-r>", "<CMD>AutolistRecalculate<CR>", { buf = 0 })
vim.keymap.set("n", "dd", "dd<CMD>AutolistRecalculate<CR>", { buf = 0 })
vim.keymap.set("v", "d", "d<CMD>AutolistRecalculate<CR>", { buf = 0 })

-- This is a bullet tester adapted from autolist
local function needs_bullet(line)
	local filetype_lists = require("autolist.config").lists[vim.bo.filetype]
	for _, pattern in ipairs(filetype_lists) do
		local matched_bare = line:match("^%s*" .. pattern .. "%s+") -- only bullet, require space after marker
		local matched_with_checkbox = line:match("^%s*" .. pattern .. "%s+" .. "%[.%]" .. "%s*") -- bullet and checkbox
		local matched_eol = line:match("^%s*" .. pattern .. "%s*$") -- bare marker at end of line (no content after)
		if matched_with_checkbox or matched_bare or matched_eol then
			return true
		end
	end
	return false
end

local MiniKeymapAddons = {
	autolist_cr = {
		condition = function()
			return needs_bullet(vim.api.nvim_get_current_line())
		end,
		action = function()
			return "<CR><CMD>AutolistNewBullet<CR>"
		end,
	},
	autolist_tab = {
		condition = function()
			return needs_bullet(vim.api.nvim_get_current_line())
		end,
		action = function()
			return "<CMD>AutolistTab<CR>"
		end,
	},
	autolist_detab = {
		condition = function()
			return needs_bullet(vim.api.nvim_get_current_line())
		end,
		action = function()
      return "<CMD>AutolistShiftTab<CR>"
		end,
	},
}

-- Tab/S-Tab indents/de-indents lists in markdown
require("mini.keymap").map_multistep("i", "<Tab>", {
	MiniKeymapAddons.autolist_tab,
	"minisnippets_next",
	"increase_indent",
	"minisnippets_expand",
	"pmenu_next",
}, { buf = 0 })
require("mini.keymap").map_multistep("i", "<S-Tab>", {
  MiniKeymapAddons.autolist_detab,
	"minisnippets_prev",
	"decrease_indent",
	"pmenu_prev",
}, { buf = 0 })
-- CR for lists in markdown
require("mini.keymap").map_multistep("i", "<CR>", {
	MiniKeymapAddons.autolist_cr,
	"pmenu_accept",
	"minipairs_cr",
}, { buf = 0 })
