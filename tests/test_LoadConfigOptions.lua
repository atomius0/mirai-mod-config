-- unit tests for LoadConfigOptions.lua

-- add the parent directory to package.path:
package.path = "../?.lua" .. package.path

local lu  = require "luaunit"

DEBUG = true

if DEBUG then
	require "strict"
	function DebugLog(...) print("DEBUG: ", ...) end
else
	function DebugLog(...) --[[ do nothing ]] end
end


local lco = require "LoadConfigOptions"


test_LoadConfigOptions = {
	setUp = function()
		print("SetUp was called!!")
	end,
	
	test_dummy = function()
		print("dummy")
	end,
}


os.exit(lu.LuaUnit.run())
