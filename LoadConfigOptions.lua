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

-- character codes:
local CC_MINUS                = string.byte("-")
local CC_DOUBLE_QUOTE         = string.byte('"')
local CC_SINGLE_QUOTE         = string.byte("'")
local CC_SQUARE_BRACKET_CLOSE = string.byte("]")
local CC_EQUALS               = string.byte("=")
local CC_CURLY_BRACE_OPEN     = string.byte("{")
local CC_COMMA                = string.byte(",")
local CC_CURLY_BRACE_CLOSE    = string.byte("}")
--TODO: remove commented out character code blocks from this module

local M = {} -- the module table

function M.StripComments(line)
	-- check if the line contains a comment first:
	if su.startsWith(line, "--") then return "" end -- shortcut if the whole line is a comment
	if not line:find("--", 1, true) then return su.trim(line) end
	
	-- character codes:
	--local minus = string.byte("-")
	--local dquote = string.byte('"')
	--local squote = string.byte("'")
	
	local tmp = ""
	local minusfound = 0
	local in_dquote = false -- are we inside a "double quoted string"?
	local in_squote = false -- are we inside a 'single quoted string'?
	local done = false
	
	for i = 1, #line do
		repeat
			local c = line:byte(i)
			
			if c == CC_DOUBLE_QUOTE and not in_squote then
				in_dquote = not in_dquote
				tmp = tmp .. string.char(c)
				break
				
			elseif c == CC_SINGLE_QUOTE and not in_dquote then
				in_squote = not in_squote
				tmp = tmp .. string.char(c)
				break
			end
			
			-- TODO: support for \ escape character?
			
			if c == CC_MINUS and not in_dquote and not in_squote then
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


-- reads the tactic from 'line' and returns it as a table.
-- a tactic table looks like this:
-- {ID, "NAME", 'BEHA_*', 'WITH_*', LVL, AAA}

-- BEHA_* and WITH_* are strings, so their constant values don't need to be known by this module.
-- this simplifies adding new behaviours.
-- AAA is always -1 (disabled), because we don't support it.

-- comments are stored like this: (detect them by their name starting with "--")
-- { 0, "-- comment", "BEHA_avoid", "WITH_no_skill", 1, -1}
function M.GetTact(line)
	if su.startsWith(line, "--") then -- comment:
		return {0, line, "BEHA_avoid", "WITH_no_skill", 1, -1}
	
	elseif #line == 0 then -- empty line:
		return nil
		
	elseif not su.startsWith(line, "Tact[") then -- error: not a tactic
		error("Expected tactic, got: '" .. line .. "'")
	end
	
	line = M.StripComments(line) -- strip comment from the end of the line, if there is one.
	
	local state = 1
	local done  = false
	
	local tmp = "" -- temporary string, used inside the state machine below
	local t_id, t_name, t_beha, t_with, t_lvl, t_aaa
	t_aaa = -1 -- default value when AAA is not specified in the tactic
	
	-- character codes:
	--local c_square_bracket_close = string.byte("]")
	--local c_equals               = string.byte("=")
	--local c_curly_brace_open     = string.byte("{")
	--local c_doublequote          = string.byte('"')
	--local c_comma                = string.byte(",")
	--local c_curly_brace_close    = string.byte("}")
	
	for i = 1, #line do
		repeat -- for 'continue' emulation via 'break'
			local c = line:byte(i)
			
			if state == 1 then -- read ID: search to beginning of ID, then read until "]"
				if i <= 5 then break end -- skip "Tact["
				if c == CC_SQUARE_BRACKET_CLOSE then -- reached "]", end of ID
					t_id = tonumber(tmp) -- set the ID variable
					tmp = ""
					state = state + 1
					break
				end
				tmp = tmp .. string.char(c)
				
			elseif state == 2 then -- read until "="
				if c == CC_EQUALS then state = state + 1 end
				
			elseif state == 3 then -- read until "{"
				if c == CC_CURLY_BRACE_OPEN then state = state + 1 end
				
			elseif state == 4 then -- read until double quote '"'
				if c == CC_DOUBLE_QUOTE then state = state + 1 end
				
			elseif state == 5 then -- read string 't_name' until the next double quote '"'
				if c == CC_DOUBLE_QUOTE then
					t_name = tmp
					tmp = ""
					state = state + 1
					break
				end
				tmp = tmp .. string.char(c)
				
			elseif state == 6 then -- read until next ","
				if c == CC_COMMA then state = state + 1 end
				
			elseif state == 7 then -- read the 'BEHA_*' constant, until next ","
				if c == CC_COMMA then
					t_beha = su.trim(tmp) -- trim it, since it isn't enclosed within quotes
					tmp = ""
					state = state + 1
					break
				end
				tmp = tmp .. string.char(c)
				
			elseif state == 8 then -- read the 'WITH_*' constant, until next ","
				if c == CC_COMMA then
					t_with = su.trim(tmp)
					tmp = ""
					state = state + 1
					break
				end
				tmp = tmp .. string.char(c)
				
			elseif state == 9 then -- read number 't_lvl', until next ","
				if c == CC_COMMA then
					t_lvl = tonumber(tmp)
					tmp = ""
					state = state + 1
					break
				end
				tmp = tmp .. string.char(c)
				
			elseif state == 10 then -- read number 't_aaa' if it exists:
				if c == CC_CURLY_BRACE_CLOSE then -- if we read '}', we are done
					if #tmp ~= 0 then
						t_aaa = tonumber(tmp)
						tmp = ""
						state = state + 1
					end
					done = true
				end
				tmp = tmp .. string.char(c)
				
			else -- reached the end of the tactic:
				-- there shouldn't be anything left in the string,
				-- since the comments have been stripped already...
				
				-- DEBUG
				for i,v in ipairs{t_id, t_name, t_beha, t_with, t_lvl, t_aaa} do print("++++",i,v) end
				-- end DEBUG
				error("Expected end of tactic: '" .. line .. "'")
			end
		until true
	end
	
	
	assert(done, "Incomplete tactic: '" .. line .. "', state: " .. state)
	
	return {t_id, t_name, t_beha, t_with, t_lvl, t_aaa}
	--return {t_id, t_name, t_beha, t_with, t_lvl}
end

---[[
if DEBUG then
	function M.TactToString(tact)
		assert(type(tact) == "table")
		
		if #tact == 5 then
			return string.format('{%4d, "%s", "%s", "%s", %d}',
				tact[1], tact[2], tact[3], tact[4], tact[5]
			)
		elseif #tact == 6 then
			return string.format('{%4d, "%s", "%s", "%s", %d, %2d}',
				tact[1], tact[2], tact[3], tact[4], tact[5], tact[6]
			)
		else
			error("invalid tact table")
		end
	end
end
--]]

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
-- {ID, "NAME", 'BEHA_*', 'WITH_*', LVL, AAA}
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
			--DebugLog(line)
			line = su.trim(line)
			
			if inTactList then
				if line == "-- End Tact" then -- end of tact list
					inTactList = false        -- go back to handling regular options
					DebugLog("## inTactList = false ##")
					break
				end
				
				local tact = M.GetTact(line) -- can return nil (ie: on empty input line)
				if tact then table.insert(tactics, tact) end
				
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
