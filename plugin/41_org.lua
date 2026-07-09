-- Much of this configuration has been sourced from: https://github.com/pkazmier/nvim/blob/e2d95b8d01513a2b4707cc9d21107b4269c05e0f/plugin/other/10_orgmode.lua#L309
Config.now(function()
	vim.pack.add({
		"https://github.com/nvim-orgmode/orgmode",
		"https://github.com/chipsenkbeil/org-roam.nvim",
	})

	local ORG_ROOT = vim.fn.expand("~/org") .. "/"
	local function org_rel(p)
		return (p:gsub("^" .. vim.pesc(ORG_ROOT), ""))
	end

	require("orgmode").setup({
		org_agenda_files = {
			ORG_ROOT .. "todo.org",
			ORG_ROOT .. "inbox.org",
			ORG_ROOT .. "appointments.org",
		},
		org_default_notes_file = ORG_ROOT .. "inbox.org",
		win_split_mode = function(name)
			local bufnr = vim.api.nvim_create_buf(false, false)
			--- Setting buffer name is required
			vim.api.nvim_buf_set_name(bufnr, name)
			vim.api.nvim_win_set_buf(0, bufnr)
		end,
	})
	require("org-roam").setup({
		directory = ORG_ROOT .. "org-roam",
	})

	-- Experimental LSP support
	vim.lsp.enable("org")

	Config.org_files = function()
		require("mini.pick").builtin.cli({
			command = { "rg", "--files", "--glob", "*.org", "--color=never" },
			postprocess = function(paths)
				local items = {}
				for _, p in ipairs(paths) do
					if p ~= "" then
						local name = vim.fn.fnamemodify(p, ":t:r"):gsub("_", " ")
						items[#items + 1] = { text = name, path = ORG_ROOT .. p }
					end
				end
				return items
			end,
		}, { source = { name = "Org files", cwd = ORG_ROOT } })
	end

	Config.org_headlines = function()
		local o = require("orgmode").instance()
		o.files:load() -- idempotent
		local items = {}
		for _, file in ipairs(o.files:all()) do
			local short = org_rel(file.filename)
			for _, h in ipairs(file:get_headlines()) do
				items[#items + 1] = {
					text = ("%s  %s"):format(short, h:get_title()),
					path = file.filename,
					lnum = h:get_range().start_line,
				}
			end
		end
		if vim.tbl_isempty(items) then
			return
		end
		require("mini.pick").start({ source = { name = "Org headlines", items = items } })
	end

	Config.org_grep = function()
		require("mini.pick").builtin.grep_live({}, { source = { cwd = ORG_ROOT } })
	end

	require("mini.pick").registry.org_headlines = Config.org_headlines
	require("mini.pick").registry.org_grep = Config.org_grep
	require("mini.pick").registry.org_files = Config.org_files
end)
