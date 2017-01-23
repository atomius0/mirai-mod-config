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
	
	test_StripComments = function()
		lu.assertEquals(lco.StripComments(
			""),
			""
		)
		lu.assertEquals(lco.StripComments( -- single minus is not a comment, stays as is.
			"-"),
			"-"
		)
		lu.assertEquals(lco.StripComments( -- a comment without anything else, gets stripped.
			"--"),
			""
		)
		lu.assertEquals(lco.StripComments( -- comment with one more -, gets stripped
			"---"),
			""
		)
		
		--[[ template, copy this:
		lu.assertEquals(lco.StripComments(
			""),
			""
		)
		--]]
	end,
}


os.exit(lu.LuaUnit.run())
