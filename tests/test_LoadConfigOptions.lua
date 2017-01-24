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
		if DEBUG then print() end -- print linebreak
	end,
	
	test_StripComments = function()
		lu.assertEquals(lco.StripComments( -- empty string should stay empty
			""),
			""
		)
		lu.assertEquals(lco.StripComments( -- spaces get stripped
			" "),
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
		lu.assertEquals(lco.StripComments( -- more - characters
			"----"),
			""
		)
		lu.assertEquals(lco.StripComments( -- even more
			"-----"),
			""
		)
		lu.assertEquals(lco.StripComments( -- a lot of them
			"------------------------------------------------------------------------------------"),
			""
		)
		lu.assertEquals(lco.StripComments( -- no comments here
			"a"),
			"a"
		)
		lu.assertEquals(lco.StripComments(
			"ab"),
			"ab"
		)
		lu.assertEquals(lco.StripComments(
			"foo"),
			"foo"
		)
		lu.assertEquals(lco.StripComments( -- still no comment
			"bar-"),
			"bar-"
		)
		lu.assertEquals(lco.StripComments( -- comment without space
			"bar--"),
			"bar"
		)
		lu.assertEquals(lco.StripComments( -- also a comment without space
			"bar---"),
			"bar"
		)
		lu.assertEquals(lco.StripComments( -- not a comment, with space before it
			"bar -"),
			"bar -"
		)
		lu.assertEquals(lco.StripComments( -- a comment with space before it
			"bar --"),
			"bar"
		)
		lu.assertEquals(lco.StripComments( -- also a comment with space before it
			"bar ---"),
			"bar"
		)
		lu.assertEquals(lco.StripComments(
			"Hello, World!"),
			"Hello, World!"
		)
		lu.assertEquals(lco.StripComments(
			"This--is a comment"),
			"This"
		)
		
		-- more complex tests:
		
		lu.assertEquals(lco.StripComments( -- no comment, but multiple single minus chars
			"local single_minus = single - minus-test"),
			"local single_minus = single - minus-test"
		)
		lu.assertEquals(lco.StripComments( -- as above, but with a comment
			"local single_minus = single - minus-test2 -- number2"),
			"local single_minus = single - minus-test2"
		)
		lu.assertEquals(lco.StripComments( -- two - separated by a space,
			"Hello- -World -nocomment"),   -- and a word prefixed with single - at the end.
			"Hello- -World -nocomment"
		)
		
		-- tests with quotes:
		
		lu.assertEquals(lco.StripComments( -- string literal, no comment
			'testline = "-- lol"'),
			'testline = "-- lol"'
		)
		lu.assertEquals(lco.StripComments( -- string literal with comment at the end
			'testline = "-- lol" -- rofl'),
			'testline = "-- lol"'
		)
		lu.assertEquals(lco.StripComments( -- as above, but with single quotes, no comment
			"testline = '-- lol'"),
			"testline = '-- lol'"
		)
		lu.assertEquals(lco.StripComments( -- as above, single quotes, comment at the end
			"testline = '-- lol' -- rofl"),
			"testline = '-- lol'"
		)
		lu.assertEquals(lco.StripComments( -- empty string literal, comment at the end
			'"" -- test'),
			'""'
		)
		lu.assertEquals(lco.StripComments( -- as above, but with single quotes.
			"'' -- test"),
			"''"
		)
		lu.assertEquals(lco.StripComments( -- single double quote, should stay as is.
			'"'),
			'"'
		)
		lu.assertEquals(lco.StripComments( -- single quote, should stay as is.
			"'"),
			"'"
		)
		lu.assertEquals(lco.StripComments( -- empty pair of double quotes, should stay as is.
			'""'),
			'""'
		)
		lu.assertEquals(lco.StripComments( -- empty pair of single quotes, should stay as is.
			"''"),
			"''"
		)
		lu.assertEquals(lco.StripComments( -- three double quotes, should stay as is.
			'"""'),
			'"""'
		)
		lu.assertEquals(lco.StripComments( -- three single quotes, should stay as is.
			"'''"),
			"'''"
		)
		lu.assertEquals(lco.StripComments( -- one pair and one separate double quote
			[["--"--"]]),
			[["--"]]
		)
		lu.assertEquals(lco.StripComments( -- one pair and one separate single quote
			[['--'--']]),
			[['--']]
		)
		lu.assertEquals(lco.StripComments( -- comment including a double quote
			'foo --"bar'),
			"foo"
		)
		lu.assertEquals(lco.StripComments( -- comment including a single quote
			"foo --'bar"),
			"foo"
		)
		lu.assertEquals(lco.StripComments( -- comment including a pair of double quotes
			'foo --"bar"'),
			"foo"
		)
		lu.assertEquals(lco.StripComments( -- comment including a pair of single quotes
			"foo --'bar'"),
			"foo"
		)
		lu.assertEquals(lco.StripComments( -- same as above, but with more stuff at the end (double)
			'foo --"bar" test'),
			"foo"
		)
		lu.assertEquals(lco.StripComments( -- same as above, but with more stuff at the end (single)
			"foo --'bar' test"),
			"foo"
		)
		
		-- mixed single and double quotes:
		
		lu.assertEquals(lco.StripComments( -- a double quote inside a pair of single quotes
			[['"--']]),
			[['"--']]
		)
		lu.assertEquals(lco.StripComments( -- a single quote inside a pair of double quotes
			[["'--"]]),
			[["'--"]]
		)
		lu.assertEquals(lco.StripComments( -- as above, with comment at the end (double in single)
			[['"--' -- comment]]),
			[['"--']]
		)
		lu.assertEquals(lco.StripComments( -- as above, with comment at the end (single in double)
			[["'--" -- comment]]),
			[["'--"]]
		)
		
		-- the same four as above, but reversed:
		
		lu.assertEquals(lco.StripComments( -- a double quote inside a pair of single quotes
			[['--"']]),
			[['--"']]
		)
		lu.assertEquals(lco.StripComments( -- a single quote inside a pair of double quotes
			[["--'"]]),
			[["--'"]]
		)
		lu.assertEquals(lco.StripComments( -- as above, with comment at the end (double in single)
			[['--"' -- comment]]),
			[['--"']]
		)
		lu.assertEquals(lco.StripComments( -- as above, with comment at the end (single in double)
			[["--'" -- comment]]),
			[["--'"]]
		)
		
		--[[ template, copy this:
		lu.assertEquals(lco.StripComments(
			""),
			""
		)
		--]]
	end,
	
	
	test_GetTact = function()
		assert(false) -- TODO: test_GetTact
	end,
	
	
	test_GetOption = function()
		assert(false) -- TODO: test_GetOption
	end,
	
	
	test_LoadConfigOptions = function()
		assert(false) -- TODO: test_LoadConfigOptions
	end,
	
	
	--[[
	test_StripComments_withQuotes = function()
		-- TODO: don't use this. keep everything related to StripComments in single function!
	end,
	--]]
}


os.exit(lu.LuaUnit.run())
