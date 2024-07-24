local M = {}

-- Functions {{{
-- Open or close quickfix or loclist
function M.list_toggle(pfx, force_open)
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
function M.grep_or_qfgrep()
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

return M
