local M = {}

function M.setup()
	-- Formatting:
	vim.api.nvim_create_user_command("Format", function(args)
		local buf = vim.api.nvim_get_current_buf()
		local ft = vim.opt_local.filetype:get()
		local has_formatter, config = pcall(require, "formatter.config")
		if has_formatter and config.values.filetype[ft] ~= nil then
			require("formatter.format").format(args.args, args.mod, args.line1, args.line2)
		elseif vim.b.neovim_config_lsp_can_format then
			vim.lsp.buf.format({
				bufnr = buf,
			})
		else
			vim.api.nvim_feedkeys("mxgggqG`x", "x", true)
		end
	end, {
		desc = "Formatting with formatter.nvim, lsp, fallback",
		force = true,
		range = "%",
		nargs = "?",
	})

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
end

return M
