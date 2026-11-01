local M = {}

---@return string?
function M.diagnostics()
	local status = vim.diagnostic.status(0)

	if status == '' then
		return nil
	end

	return '‹› ' .. status
end

return M