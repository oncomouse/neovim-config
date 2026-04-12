vim.b.minisurround_config = {
	custom_surroundings = {
		s = {
			input = { "%[%[().-()%]%]" },
			output = { left = "[[", right = "]]" },
		},
	},
}

local spec_pair = require("mini.ai").gen_spec.pair
vim.b.miniai_config = {
	custom_textobjects = {
		["s"] = spec_pair("[[", "]]"),
	},
}
