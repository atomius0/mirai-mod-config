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


if DEBUG then print() end -- print linebreak

--test_LoadConfigOptions = {}
test_lco = {}


function test_lco.test_StripComments()
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
end


function test_lco.test_GetTact()
	
	-- simple tests:
	
	lu.assertEquals(lco.GetTact(
		'Tact[1261] = {"Wild Rose", BEHA_react, WITH_full_power, 5, 0}'),
		{1261, "Wild Rose", "BEHA_react", "WITH_full_power", 5, 0}
	)
	lu.assertEquals(lco.GetTact(
		'Tact[1002] = {"Poring", BEHA_attack_last, WITH_no_skill, 5, -1} -- comment'),
		{1002, "Poring", "BEHA_attack_last", "WITH_no_skill", 5, -1}
	)
	lu.assertEquals(lco.GetTact(
		'Tact[1097] = {"Ant Egg", BEHA_attack_last, WITH_no_skill, 5, 0}'),
		{1097, "Ant Egg", "BEHA_attack_last", "WITH_no_skill", 5, 0}
	)
	lu.assertEquals(lco.GetTact( -- missing AAA parameter, no comma at the end
		'Tact[1097] = {"Ant Egg", BEHA_attack_last, WITH_no_skill, 5}'),
		{1097, "Ant Egg", "BEHA_attack_last", "WITH_no_skill", 5, -1}
	)
	lu.assertEquals(lco.GetTact( -- missing AAA parameter, but with comma at the end
		'Tact[1097] = {"Ant Egg", BEHA_attack_last, WITH_no_skill, 5,}'),
		{1097, "Ant Egg", "BEHA_attack_last", "WITH_no_skill", 5, -1}
	)
	lu.assertEquals(lco.GetTact( -- missing AAA parameter, but with comma and space at the end
		'Tact[1097] = {"Ant Egg", BEHA_attack_last, WITH_no_skill, 5, }'),
		{1097, "Ant Egg", "BEHA_attack_last", "WITH_no_skill", 5, -1}
	)
	lu.assertEquals(lco.GetTact( -- missing AAA parameter, but with comma and tab at the end
		'Tact[1097] = {"Ant Egg", BEHA_attack_last, WITH_no_skill, 5,\t}'),
		{1097, "Ant Egg", "BEHA_attack_last", "WITH_no_skill", 5, -1}
	)
	lu.assertEquals(lco.GetTact( -- missing AAA parameter, but with comma and whitespace at the end
		'Tact[1097] = {"Ant Egg", BEHA_attack_last, WITH_no_skill, 5, \t\t  \t }'),
		{1097, "Ant Egg", "BEHA_attack_last", "WITH_no_skill", 5, -1}
	)
	
	-- comments:
	
	lu.assertEquals(lco.GetTact(
		'-- testing a comment'),
		{0, "-- testing a comment", "BEHA_avoid", "WITH_no_skill", 1, -1}
	)
	lu.assertEquals(lco.GetTact(
		'--'),
		{0, "--", "BEHA_avoid", "WITH_no_skill", 1, -1}
	)
	
	-- errors:
	
	lu.assertErrorMsgContains("Expected tactic, got: '", lco.GetTact, "foobar = 12")
	lu.assertErrorMsgContains("Expected tactic, got: '", lco.GetTact, "Tact(1234) = {baz}")
	
	lu.assertErrorMsgContains("Expected end of tactic: '", lco.GetTact,
		'Tact[1261] = {"Wild Rose", BEHA_react, WITH_full_power, 5, 0}-'
	)
	lu.assertErrorMsgContains("Expected end of tactic: '", lco.GetTact,
		'Tact[1261] = {"Wild Rose", BEHA_react, WITH_full_power, 5, 0} e'
	)
	lu.assertErrorMsgContains("Expected end of tactic: '", lco.GetTact,
		'Tact[1261] = {"Wild Rose", BEHA_react, WITH_full_power, 5, 0}; Tact[4321] = {stuff}'
	)
	
	lu.assertErrorMsgContains("Incomplete tactic: '", lco.GetTact, -- missing closing brace '}'
		'Tact[1261] = {"Wild Rose", BEHA_react, WITH_full_power, 5, 0'
	)
	lu.assertErrorMsgContains("Incomplete tactic: '", lco.GetTact, -- cut off before last parameter
		'Tact[1261] = {"Wild Rose", BEHA_react, WITH_full_power, 5, '
	)
	lu.assertErrorMsgContains("Incomplete tactic: '", lco.GetTact, -- cut off even earlier
		'Tact[1261] = {"Wild Rose", BEHA_react, WITH_full_power, 5'
	)
	lu.assertErrorMsgContains("Incomplete tactic: '", lco.GetTact, -- as above, even earlier
		'Tact[1261] = {"Wild Rose", BEHA_react, WITH_full_power'
	)
	lu.assertErrorMsgContains("Incomplete tactic: '", lco.GetTact, -- cut in the middle of a word
		'Tact[1261] = {"Wild Rose", BEHA_react, WITH_fu'
	)
	lu.assertErrorMsgContains("Incomplete tactic: '", lco.GetTact, -- as above
		'Tact[1261] = {"Wi'
	)
	lu.assertErrorMsgContains("Incomplete tactic: '", lco.GetTact, -- only tact identifier left
		'Tact['
	)
	
	-- this one is not recognized as a tactic, because the identifier 'Tact[' is incomplete:
	lu.assertErrorMsgContains("Expected tactic, got: '", lco.GetTact,
		'Tact'
	)
	lu.assertErrorMsgContains("Expected tactic, got: '", lco.GetTact, -- as above
		'Tac'
	)
	lu.assertErrorMsgContains("Expected tactic, got: '", lco.GetTact, -- as above
		'T'
	)
	
	-- an empty tact string results in a return value of nil:
	lu.assertEquals(lco.GetTact(""), nil)
	
	
	--[[ template:
	lu.assertEquals(lco.GetTact(
		''),
		{0, "", "", "", 0, 0}
	)
	--]]
	
	--assert(false) -- TODO: test_GetTact
end


function test_lco.test_GetOption()
	
	-- simple tests:
	
	lu.assertEquals(lco.GetOption("option=true"), {"option", "true"}) -- normal option
	lu.assertEquals(lco.GetOption("option = true"), {"option", "true"}) -- normal option with space
	lu.assertEquals(lco.GetOption("="), {"", ""}) -- single equals sign
	lu.assertEquals(lco.GetOption(" ="), {"", ""}) -- single equals with space
	lu.assertEquals(lco.GetOption(" = "), {"", ""}) -- single equals with spaces
	
	-- more complex tests:
	
	lu.assertEquals(lco.GetOption("AS_FIL_FLTT.MinSP=70"), {"AS_FIL_FLTT.MinSP", "70"})
	
	lu.assertEquals(lco.GetOption( -- option with multiple spaces
		" option with spaces  = true and false"),
		{"option with spaces", "true and false"}
	)
	lu.assertEquals(lco.GetOption(
		"CIRCLE_ON_IDLE        = 1     -- 0 disabled"),
		{"CIRCLE_ON_IDLE", "1     -- 0 disabled"}
	)
	lu.assertEquals(lco.GetOption(
		'Tact[1002] = {"Poring", BEHA_attack_last, WITH_no_skill, 5, -1}'),
		{'Tact[1002]', '{"Poring", BEHA_attack_last, WITH_no_skill, 5, -1}'}
	)
	
	-- errors:
	
	lu.assertErrorMsgContains("invalid option: ", lco.GetOption, "") -- no equals sign
	lu.assertErrorMsgContains("invalid option: ", lco.GetOption, "no equals sign here")
	lu.assertErrorMsgContains("invalid option: ", lco.GetOption, "too = many = equals")
	lu.assertErrorMsgContains("invalid option: ", lco.GetOption, "-")
	lu.assertErrorMsgContains("invalid option: ", lco.GetOption, "--")
	lu.assertErrorMsgContains("invalid option: ", lco.GetOption, "---")
	lu.assertErrorMsgContains("invalid option: ", lco.GetOption, "this == 1")
	
	lu.assertErrorMsgContains("invalid option: ", lco.GetOption,
		"CIRCLE_ON_IDLE        = 1     -- 0 = disabled" -- contains two equals signs.
	)
	
	--[[ -- template:
	lu.assertEquals(lco.GetOption(""), {"", ""})
	--]]
end

--[[
function test_lco.test_LoadConfigOptions()
	assert(false) -- TODO: test_LoadConfigOptions
end
--]]

os.exit(lu.LuaUnit.run())
