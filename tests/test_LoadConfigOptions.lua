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


local lco  = require "LoadConfigOptions"
local femu = require "fileEmulator"

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


function test_lco.test_LoadConfigOptions()
	
	local f -- file emu handle
	local opts, tact -- tables returned by lco.LoadConfigOptions
	
	-- slightly modified version of default Config.lua
	f = femu([[
		CIRCLE_ON_IDLE        = 1     -- 0 = disabled
		FOLLOW_AT_ONCE        = 1     -- 0 = disabled. Follow at once the owner if he/she moves away from the enemy
		HELP_OWNER_1ST        = true  -- true = when the homunculus is in battle, he/she can switch target to help the owner
		KILL_YOUR_ENEMIES_1ST = false -- true = the homunculus kills ALL his/her enemies before to help the owner
		LONG_RANGE_SHOOTER    = false -- true = the homunculs doesn't go to monters and just casts long range attacks, until the monster come close
		BOLTS_ON_CHASE_ST     = false -- true = alchemist can cast bolts when the omunculus is chasing/intercepting a monster
		HP_PERC_DANGER        = 50    -- HP% below that value makes your homunculus to evade the monsters
		HP_PERC_SAFE2ATK      = 75    -- The AI is not aggressive until the homunculus reaches this HP% (> 100 = never agressive)
		OWNER_CLOSEDISTANCE   = 2     -- Distance to reach when the houmunculus goes to the owner
		TOO_FAR_TARGET        = 14    -- Max interception range from the owner
		SKILL_TIME_OUT        = 2000  -- The AI doesn't use aggressive skills if more than the specified milliseconds are passed
									  -- from the begin of the attack (unless the skill mode for this monster is "WITH_full_power")
		NO_MOVING_TARGETS     = false -- true = the homunculus don't attack monsters that are on movement (ie monsters that are following other players)
		ADV_MOTION_CHECK      = false -- true = it tries to detect frozen or trapped monster (for now this works for aggressive monsters only) and area spells

		-- Alchemist Auto Attacks (AAA)-------------------
		-- HP Range (no AAA when HP are out of this range)
		AAA_MinHP   = 100   --\__ to disable limits: set AAA_MinHP = 0 and AAA_MaxHP = a very high value,
		AAA_MaxHP   = 32000 --/   that your alchemist will never reach (eg. 32000)
		-- Cart Revolution
		ACR = {}
		ACR.MinEnemies = 2  -- Minimum enemies (0=disabled, no Cart Revolution)
		ACR.MinSP   = 20 -- Minimum SP to use Auto Cart Revolution
		-- (single target) Weapon-based skill
		AST = {}
		AST.SkillID = 0  -- 0 = disabled, 5=Bash(Cultus), 14=Cold Bolt(Ice Falchion), 19 = Firebolt (Fireblend), 337 = Tomahawk Throwing (Tomahawk)
		AST.MinSP   = 20 -- Minimum SP to use an Auto Single Target weapon-based attak
		AST.Level   = 5

		-- Auto-Aid Potion (AAP) -------------------------
		CAN_DETECT_NOPOT = true
		AAP = {}
		AAP.Mode    = 3    -- set this to 0 to disable AAP
		AAP.HP_Perc = 65   -- if the HP are below this percentage, an AAP (or Healing Touch) is casted
						   -- select a % that an AAP can returns HP above HOMUN_SAFE_HP_PERC
		AAP.Level   = 2    -- lvl 2 throws orange potions

		-- Homunculus skills -----------------------------
		-- Here you can configure skill levels and the minimum SP amount required in order
		-- to activate a skill (the AI will not cast that skill until your homunculus has
		-- more SPs than the specified value).

		-- Amistr
		AS_AMI_BULW = {} -- Bulwark
		AS_AMI_BULW.MinSP=40
		AS_AMI_BULW.Level=5

		AS_AMI_CAST = {} -- Castling
		AS_AMI_CAST.MinSP=10
		AS_AMI_CAST.Level=0 -- disabled

		-- Filir
		AS_FIL_MOON = {} -- Moonlight
		AS_FIL_MOON.MinSP=20 -- set this to 90, to preserve 70 SP for flitting
		AS_FIL_MOON.Level=5

		AS_FIL_ACCL = {} -- Accelerated Flight
		AS_FIL_ACCL.MinSP=70
		AS_FIL_ACCL.Level=0 -- disabled

		AS_FIL_FLTT = {} -- Flitting
		AS_FIL_FLTT.MinSP=70
		AS_FIL_FLTT.Level=5

		-- Lif
		AS_LIF_HEAL = {} -- Healing touch
		AS_LIF_HEAL.MinSP=40
		AS_LIF_HEAL.Level=5

		AS_LIF_ESCP = {} -- Urgent escape
		AS_LIF_ESCP.MinSP=40
		AS_LIF_ESCP.Level=5

		-- Vanilmirth
		AS_VAN_CAPR = {} -- Caprice
		AS_VAN_CAPR.MinSP=30
		AS_VAN_CAPR.Level=5

		AS_VAN_BLES = {} -- Chaotic Blessings
		AS_VAN_BLES.MinSP=40
		AS_VAN_BLES.Level=0 -- lvl 4 heals chances: 36% enemy, 60% self, 4% owner

		-- Tact list: behaviour for each monster ---------
		-- format: Tact[ID] = {"Name", behaviour, skill mode}
		-- ID: please check ROEmpire database for more IDs: http://www.roempire.com/database/?page=monsters
		-- Name: this is just for you, the AI only checks the ID
		-- Behaviours and skill modes: you can find the list in Const.lua
		DEFAULT_BEHA = BEHA_attack     -- \__ values assumed for any monster not listed below
		DEFAULT_WITH = WITH_slow_power -- /
		Tact = {}
		Tact[1261] = {"Wild Rose", BEHA_react, WITH_full_power, 5, 0}
		-- Orc Dungeon (lvl 50+ Settings)
		Tact[1189] = {"Orc Archer", BEHA_react_1st, WITH_full_power, 5, 0}
		Tact[1177] = {"Zenorc", BEHA_attack_1st, WITH_full_power, 5, 0}
		Tact[1152] = {"Orc Skeleton", BEHA_react, WITH_one_skill, 5, 0}
		Tact[1111] = {"Drainliar", BEHA_attack_weak, WITH_no_skill, 1, 0}
		Tact[1042] = {"Steel Chonchon", BEHA_attack_last, WITH_one_skill, 1, 0}
		]]--[[-- Poring and Metaling fields
		Tact[1368] = {"Geographer", BEHA_avoid, WITH_no_skill, 5, 0}
		Tact[1118] = {"Flora", BEHA_coward, WITH_full_power, 5, 0}
		Tact[1613] = {"Metaling", BEHA_react, WITH_one_skill, 5, 0}
		Tact[1031] = {"Poporing", BEHA_react, WITH_one_skill, 5, 0}
		Tact[1242] = {"Marin", BEHA_react, WITH_no_skill, 5, 0}
		Tact[1113] = {"Drops", BEHA_attack, WITH_no_skill, 5, -1}
		Tact[1002] = {"Poring", BEHA_attack_last, WITH_no_skill, 5, -1}
		-- Eggs
		Tact[1008] = {"Pupa", BEHA_attack_last, WITH_no_skill, 5, 0}
		Tact[1048] = {"Thief Bug Egg", BEHA_attack_last, WITH_no_skill, 5, 0}
		Tact[1047] = {"Peco Peco Egg", BEHA_attack_last, WITH_no_skill, 5, 0}
		Tact[1097] = {"Ant Egg", BEHA_attack_last, WITH_no_skill, 5, 0}
		-- Summoned Plants
		Tact[1555] = {"Sm. Parasite", BEHA_avoid, WITH_no_skill, 5, 0}
		Tact[1575] = {"Sm. Flora", BEHA_avoid, WITH_no_skill, 5, 0}
		Tact[1579] = {"Sm. Hydra", BEHA_avoid, WITH_no_skill, 5, 0}
		Tact[1589] = {"Sm. Mandragora", BEHA_avoid, WITH_no_skill, 5, 0}
		Tact[1590] = {"Sm. Geographer", BEHA_avoid, WITH_no_skill, 5, 0}
		-- WoE Guardians
		Tact[1285] = {"WoE Guardian 1", BEHA_avoid, WITH_no_skill, 5, 0}
		Tact[1286] = {"WoE Guardian 2", BEHA_avoid, WITH_no_skill, 5, 0}
		Tact[1287] = {"WoE Guardian 3", BEHA_avoid, WITH_no_skill, 5, 0}
		Tact[1288] = {"WoE Guardian 4", BEHA_avoid, WITH_no_skill, 5, 0}
		-- Plants and mushrooms
		Tact[1078] = {"Red Plant", BEHA_react, WITH_no_skill, 5, 0}
		Tact[1079] = {"Blue Plant", BEHA_react, WITH_no_skill, 5, 0}
		Tact[1080] = {"Green Plant", BEHA_react, WITH_no_skill, 5, 0}
		Tact[1081] = {"Yellow Plant", BEHA_react, WITH_no_skill, 5, 0}
		Tact[1082] = {"White Plant", BEHA_react, WITH_no_skill, 5, 0}
		Tact[1083] = {"Shining Plant", BEHA_react, WITH_no_skill, 5, 0}
		Tact[1084] = {"Black Mushroom", BEHA_react, WITH_no_skill, 5, 0}
		Tact[1085] = {"Red Mushroom", BEHA_react, WITH_no_skill, 5, 0}
		
		-- empty lines:
		
		
		-- Testing multiple definitions of same Tact, varied spacing and omitting AAA parameter:
		Tact[1031]={"Poporing",BEHA_react,WITH_one_skill,5,1}
		Tact[1031] ={"Poporing", BEHA_react , WITH_one_skill, 5, }
		Tact[1031]= {"Poporing",   BEHA_react, WITH_one_skill  , 5,}
		Tact[1031] = {"Poporing",BEHA_react,WITH_one_skill, 5}
		Tact[1031] = {"Poporing",BEHA_react,WITH_one_skill,5}
		Tact[1261] = {"Wild Rose", BEHA_react, WITH_full_power, 5}
		-- End Tact
	]])
	opts, tact = lco.LoadConfigOptions(f)
	lu.assertEquals(opts, {
		-- general options
		["CIRCLE_ON_IDLE"] = "1",
		["FOLLOW_AT_ONCE"] = "1",
		["HELP_OWNER_1ST"] = "true",
		["KILL_YOUR_ENEMIES_1ST"] = "false",
		["LONG_RANGE_SHOOTER"] = "false",
		["BOLTS_ON_CHASE_ST"] = "false",
		["HP_PERC_DANGER"] = "50",
		["HP_PERC_SAFE2ATK"] = "75",
		["OWNER_CLOSEDISTANCE"] = "2",
		["TOO_FAR_TARGET"] = "14",
		["SKILL_TIME_OUT"] = "2000",
		["NO_MOVING_TARGETS"] = "false",
		["ADV_MOTION_CHECK"] = "false",
		
		-- Alchemist Auto Attacks (AAA)
		["AAA_MinHP"] = "100",
		["AAA_MaxHP"] = "32000",
		--["ACR"] = "{}" -- tables are skipped by lco.LoadConfigOptions()
		["ACR.MinEnemies"] = "2",
		["ACR.MinSP"] = "20",
		--["AST"] = "{}"
		["AST.SkillID"] = "0",
		["AST.MinSP"] = "20",
		["AST.Level"] = "5",
		
		-- Auto-Aid Potion (AAP)
		["CAN_DETECT_NOPOT"] = "true",
		--["AAP"] = "{}",
		["AAP.Mode"] = "3",
		["AAP.HP_Perc"] = "65",
		["AAP.Level"] = "2",
		
		-- Homunculus skills
		-- Amistr
		--["AS_AMI_BULW"] = "{}", -- Bulwark
		["AS_AMI_BULW.MinSP"] = "40",
		["AS_AMI_BULW.Level"] = "5",
		--["AS_AMI_CAST"] = "{}", -- Castling
		["AS_AMI_CAST.MinSP"] = "10",
		["AS_AMI_CAST.Level"] = "0",
		-- Filir
		--["AS_FIL_MOON"] = "{}", -- Moonlight
		["AS_FIL_MOON.MinSP"] = "20",
		["AS_FIL_MOON.Level"] = "5",
		--["AS_FIL_ACCL"] = "{}", -- Accelerated Flight
		["AS_FIL_ACCL.MinSP"] = "70",
		["AS_FIL_ACCL.Level"] = "0",
		--["AS_FIL_FLTT"] = "{}", -- Flitting
		["AS_FIL_FLTT.MinSP"] = "70",
		["AS_FIL_FLTT.Level"] = "5",
		-- Lif
		--["AS_LIF_HEAL"] = "{}", -- Healing touch
		["AS_LIF_HEAL.MinSP"] = "40",
		["AS_LIF_HEAL.Level"] = "5",
		--["AS_LIF_ESCP"] = "{}", -- Urgent escape
		["AS_LIF_ESCP.MinSP"] = "40",
		["AS_LIF_ESCP.Level"] = "5",
		-- Vanilmirth
		--["AS_VAN_CAPR"] = "{}", -- Caprice
		["AS_VAN_CAPR.MinSP"] = "30",
		["AS_VAN_CAPR.Level"] = "5",
		--["AS_VAN_BLES"] = "{}", -- Chaotic Blessings
		["AS_VAN_BLES.MinSP"] = "40",
		["AS_VAN_BLES.Level"] = "0",
		
		-- Behaviours and skill modes:
		["DEFAULT_BEHA"] = "BEHA_attack",
		["DEFAULT_WITH"] = "WITH_slow_power",
		
		--[""] = "",
	})
	
	lu.assertEquals(tact, {
		{1261, "Wild Rose", "BEHA_react", "WITH_full_power", 5, 0},
		
		{0, "-- Orc Dungeon (lvl 50+ Settings)", "BEHA_avoid", "WITH_no_skill", 1, -1},
		{1189, "Orc Archer", "BEHA_react_1st", "WITH_full_power", 5, 0},
		{1177, "Zenorc", "BEHA_attack_1st", "WITH_full_power", 5, 0},
		{1152, "Orc Skeleton", "BEHA_react", "WITH_one_skill", 5, 0},
		{1111, "Drainliar", "BEHA_attack_weak", "WITH_no_skill", 1, 0},
		{1042, "Steel Chonchon", "BEHA_attack_last", "WITH_one_skill", 1, 0},
		
		--{, "", "", "", , },
		--{0, "", "BEHA_avoid", "WITH_no_skill", 1, -1},
		
		-- TODO: tact
	})
	
	
	--[[ -- template:
	f = femu("")
	opts, tact = lco.LoadConfigOptions(f)
	lu.assertEquals(opts, {})
	lu.assertEquals(tact, {})
	--]]
	
	--assert(false) -- TODO: test_LoadConfigOptions
end


os.exit(lu.LuaUnit.run())
