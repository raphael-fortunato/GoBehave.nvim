local vim = vim
local M = {}

P = function(v)
	print(vim.inspect(v))
	return v
end

M.send_command = function(cmd)
	local f = assert(io.popen(cmd, "r"))
	local s = assert(f:read("*a"))
	f:close()
	s = string.gsub(s, "^%s+", "")
	s = string.gsub(s, "%s+$", "")
	return s
end

M.get_step_python = function()
	local step_line = vim.api.nvim_get_current_line()
	if step_line:find("@given") or step_line:find("@then") or step_line:find("@when") then
		step_line = string.gsub(step_line, '@%a+%("', "")
		step_line = string.gsub(step_line, '"%)', "")
		step_line = string.gsub(step_line, "{.-}", '([^"]*)')
		return step_line
	end
end

M.get_step = function()
	local step_line = vim.api.nvim_get_current_line()
	if
		not step_line:find("Given")
		and not step_line:find("And")
		and not step_line:find("Then")
		and not step_line:find("When")
	then
		print("Line is not a step")
		return nil
	else
		step_line = string.gsub(step_line, "^%s+", "")
		step_line = string.gsub(step_line, "%s+$", "")
		return step_line
	end
end

M.get_dir = function()
	return vim.fn.expand("%:p:h")
end

M.goto_definition = function()
	local step_line = M.get_step()
	local directory = M.get_dir()
	if step_line ~= nil then
		local command = "echo '\nget_step_definition("
			.. '"'
			.. directory
			.. '",'
			.. '"'
			.. step_line
			.. "\")' | cat /home/raphael/Documents/plugins/GoBehave.nvim/autoload/goto_definition.py - |"
			.. "python -"
		local definition_file = M.send_command(command)
		if definition_file:find("edit") then
			vim.api.nvim_command(definition_file)
		else
			print("This was the result: " .. definition_file)
		end
	end
end

M.get_references = function()
	local search_query = M.get_step_python()
	require("telescope.builtin").grep_string({
		prompt_title = "< Behave References >",
		search = search_query,
		use_regex = true,
	})
end

return M
