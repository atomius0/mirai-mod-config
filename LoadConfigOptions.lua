-- mirai-mod-conf
-- function LoadConfigOptions

-- DONE: move all functions into a table M.
-- DONE: assign a metatable with a __call function to this table. the __call function should do:
--[[
mt.__call = function(t, ...)
	return t.LoadConfigOptions(...)
end
--]]
-- we do this, because then we can access all helper functions from outside this module.
-- (for unit testing)
-- while this module can still be 'require'd and used the same way as before.

-- workaround for strict.lua
-- without this, strict.lua complains: "variable 'STRINGUTIL_ADD_STRING_METHODS' is not declared",
-- because stringutil.lua checks if this global variable is defined.
if DEBUG then STRINGUTIL_ADD_STRING_METHODS = false end

local su = require "stringutil"

local M = {} -- the module table

function M.StripComments(line)
	-- check if the line contains a comment first:
	if su.startsWith(line, "--") then return "" end -- shortcut if the whole line is a comment
	if not line:find("--", 1, true) then return su.trim(line) end
	
	-- character codes:
	local minus = string.byte("-")
	local dquote = string.byte('"')
	local squote = string.byte("'")
	
	local tmp = ""
	local minusfound = 0
	local in_dquote = false -- are we inside a "double quoted string"?
	local in_squote = false -- are we inside a 'single quoted string'?
	local done = false
	
	for i = 1, #line do
		repeat
			local c = line:byte(i)
			
			if c == dquote and not in_squote then
				in_dquote = not in_dquote
				tmp = tmp .. string.char(c)
				break
				
			elseif c == squote and not in_dquote then
				in_squote = not in_squote
				tmp = tmp .. string.char(c)
				break
			end
			
			-- TODO: support for \ escape character?
			
			if c == minus and not in_dquote and not in_squote then
				minusfound = minusfound + 1
				if minusfound == 2 then
					done = true
					minusfound = 0
					break
				end
				
			elseif minusfound > 0 then -- there was a minus, but not a second one right after
				tmp = tmp .. "-" .. string.char(c)
				minusfound = 0
				
			else
				tmp = tmp .. string.char(c)
			end
		until true
		if done then break end
	end
	
	-- add skipped minus character:
	if minusfound > 0 then tmp = tmp .. "-" end
	
	--[[for i = 1, minusfound do
		tmp = tmp .. "-"
	end--]]
	
	line = su.trim(tmp)
	
	--DebugLog("StripComments: " .. line)
	return line
end


-- returns a table containing the option name and its assigned value:
-- sample input: "MY_OPTION.FOO = 123"
-- t[1] = "MY_OPTION.FOO", t[2] = "123"
function M.GetOption(line)
	local opt = su.split(line, "=", true)
	assert(#opt == 2, "invalid option: " .. line)
	opt[1] = su.trim(opt[1])
	opt[2] = su.trim(opt[2])
	return opt
end


-- loads all options from file handle 'f' and returns 2 tables:
-- 1. a table 'options' with all regular options (general and skills)
-- 2. a table 'tactics', containing a table for each tactic in the same order as they are written
--    in the config file.
-- tactic tables look like this:
-- {ID, "NAME", BEHA_*, WITH_*, LVL, AAA}
-- comments are stored like this: (detect them by their name starting with "--")
-- { 0, "-- comment", BEHA_avoid, WITH_no_skill, 1, -1}
-- see file 'ControlPanelConfigOptions.md' (line 110, "## Tact List:") for details.
function M.LoadConfigOptions(f)
	DebugLog("LoadConfigOptions()")
	
	local options = {}
	local tactics = {}
	
	local inTactList = false -- are we inside the tact list right now?
	
	for line in f:lines() do
		repeat -- emulating 'continue' support, use break within this block to 'continue' the loop
			DebugLog(line)
			line = su.trim(line)
			
			if inTactList then
				if line == "-- End Tact" then -- end of tact list
					inTactList = false        -- go back to handling regular options
					DebugLog("## inTactList = false ##")
					break
				end
				-- TODO: handle tact list
				
			else -- not inTactList, handle regular options:
				line = M.StripComments(line)
				
				-- skip empty lines
				if #line == 0 then break end
				
				-- read regular options:
				local opt = M.GetOption(line)
				
				if opt[2] == "{}" then -- if option is a table constructor:
					if opt[1] == "Tact" then -- detect start of tactics segment
						inTactList = true
						DebugLog("## inTactList = true ##")
					end
					break -- ignore all tables (except "Tact")
				end
				
				-- insert option 'opt' into table 'options':
				options[opt[1]] = opt[2]
			end
		until true
	end
	
	-- for each line in f:
	--     DebugLog(line)
	--     line = stringutil.trim(line)
	--     repeat
	--         if 
	--         if continue_condition then break end
	--     until true
	-- end
	
	return options, tactics
end


-- create a metatable, so we can call table 'M' as if it was a function:
local mt = {
	__call = function(t, ...)
		return t.LoadConfigOptions(...)
	end
}

--return LoadConfigOptions
return setmetatable(M, mt)
