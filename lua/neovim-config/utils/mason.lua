local M = {}

function M.missing_package(pkg)
	vim.notify(
		string.format("Cannot find %s! Run `:MasonInstall %s` to have this tool available.", pkg, pkg),
		vim.log.levels.WARN,
		{}
	)
end
function M.mason_package_available(mason_pkg)
	return require("mason-registry").is_installed(mason_pkg)
		or vim.fn.executable(vim.tbl_keys(require("mason-registry").get_package(mason_pkg).spec.bin)[1]) == 1
end

return M
