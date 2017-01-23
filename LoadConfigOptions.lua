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
	--if not line:find("--", 1, true) then return line end
	--if su.startsWith(line, "--") then return "" end -- shortcut if the whole line is a comment
	
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
		local c = line:byte(i)
		--print(string.char(c))
		repeat
			--[[if in_dquote then
				if c == dquote then in_dquote = false end
				tmp = tmp .. string.char(c)
				break
			end
			
			if in_squote then
				if c == squote then in_squote = false end
				tmp = tmp .. string.char(c)
				break
			end
			--]]
			---[[
			if c == dquote and not in_squote then
				in_dquote = not in_dquote
				tmp = tmp .. string.char(c)
				break
				
			elseif c == squote and not in_dquote then
				in_squote = not in_squote
				tmp = tmp .. string.char(c)
				break
			end
			--]]
			
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
	
	line = tmp
	
	DebugLog("StripComments: " .. line)
	return su.trim(line)
end


-- loads all options from file handle 'f' and returns 2 tables:
-- 1. a table 'options' with all regular options (general and skills)
-- 2. a table 'tactics', containing a table for each tactic in the same order as they are written
--    in the config file.
-- tactic tables look like this:
-- {ID, "NAME", BEHA_*, WITH_*, LVL, AAA}
-- see file 'ControlPanelConfigOptions.md' (line 110, "## Tact List:") for details.
function M.LoadConfigOptions(f)
	DebugLog("LoadConfigOptions()")
	
	local options = {}
	local tactics = {}
	
	for line in f:lines() do
		--DebugLog(line)
		line = su.trim(line)
		
		repeat -- emulating 'continue' support, use break within this block to 'continue' the loop
			-- strip comments:
			line = M.StripComments(line)
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
