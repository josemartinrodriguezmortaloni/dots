-- Per-branch session management on top of mini.sessions: sessions are
-- named after cwd + git branch, written on focus changes and exit, and
-- only activated when nvim starts without file arguments. Called from
-- init.lua.
local M = {}

-- Sanitize a string to be safe for use as a filename.
local function sanitize_for_filename(str)
	return str
		:gsub('[/%.~%^:%?%*%[\\@%s%c]+', '_')
		:gsub('_+', '_')
		:gsub('^_', '')
		:gsub('_$', '')
end

-- Outside a git repo or on a detached HEAD, git prints nothing to stdout.
local function get_session_name()
	local name = sanitize_for_filename(vim.fn.getcwd())
	local obj = vim
		.system({ 'git', 'branch', '--show-current' }, { text = true })
		:wait()
	local branch = vim.trim(obj.stdout)
	if branch == '' then
		return name
	end
	return name .. '_' .. sanitize_for_filename(branch)
end

-- A session for this branch exists, but another session is active.
local function is_other_branch_session(sessions, session_name)
	return sessions.detected[session_name] ~= nil
		and string.find(vim.v.this_session, session_name, 1, true) == nil
end

local function setup_sessions()
	local sessions = require 'mini.sessions'
	sessions.setup {
		file = '',
	}

	vim.api.nvim_create_autocmd({ 'VimEnter', 'FocusGained' }, {
		nested = true,
		callback = function()
			local session_name = get_session_name()

			-- Save session for current branch
			if vim.v.this_session ~= '' then
				sessions.write()
			end

			if is_other_branch_session(sessions, session_name) then
				return
			end
			-- If we are opening a new branch, create a session for the new branch with current state
			sessions.write(session_name)
		end,
	})

	vim.api.nvim_create_autocmd('VimLeavePre', {
		callback = function()
			if vim.v.this_session == '' then
				return
			end

			sessions.write(get_session_name())
		end,
	})
end

function M.setup()
	if vim.fn.argc(-1) == 0 then
		vim.schedule(setup_sessions)
	end
end

return M
