-- mirai-mod-conf
-- function LoadConfigOptions

-- workaround for strict.lua
-- without this, strict.lua complains: "variable 'STRINGUTIL_ADD_STRING_METHODS' is not declared",
-- because stringutil.lua checks if this global variable is defined.
if DEBUG then STRINGUTIL_ADD_STRING_METHODS = false end

local su = require "stringutil"

-- loads all options from file handle 'f' and returns 2 tables:
-- 1. a table 'options' with all regular options (general and skills)
-- 2. a table 'tactics', containing a table for each tactic in the same order as they are written
--    in the config file.
-- tactic tables look like this:
-- {ID, "NAME", BEHA_*, WITH_*, LVL, AAA}
-- see file 'ControlPanelConfigOptions.md' (line 110, "## Tact List:") for details.
local function LoadConfigOptions(f)
	DebugLog("LoadConfigOptions()")
	
	-- for each line in f:
	--     DebugLog(line)
	--     line = stringutil.strip(line)
	--     repeat
	--         if 
	--         if continue_condition then break end
	--     until true
	-- end
	
end


return LoadConfigOptions
