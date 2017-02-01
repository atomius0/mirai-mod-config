-- mirai-mod-conf
-- TacticsTab functions

local AddTacticDialog = require "AddTacticDialog"
local lch = require "ListCtrlHelper"
local su  = require "stringutil"

local M = {}


-- OnEdit and OnAdd need the xmlResource parameter, because they create a new window using
-- AddTacticDialog from the xrc file.
function M.OnEdit(listCtrl, xmlResource, parent)
	assert(listCtrl)
	assert(xmlResource)
	assert(parent)
	
	-- TODO: this
end


function M.OnAdd(listCtrl, xmlResource, parent)
	assert(listCtrl)
	assert(xmlResource)
	assert(parent)
	
	--AddTacticDialog(xmlResource, parent)
	AddTacticDialog(xmlResource, parent, {1234, "Poring", "BEHA_coward", "WITH_slow_power", 4}) -- TODO: DEBUG!!
	-- TODO: this
end


function M.OnRemove(listCtrl)
	assert(listCtrl)
	-- TODO: this
end


function M.OnUp(listCtrl)
	assert(listCtrl)
	-- TODO: this
end


function M.OnDown(listCtrl)
	assert(listCtrl)
	-- TODO: this
end


function M.Init(listCtrl)
	assert(listCtrl)
	
	--[[
	lch.InitColumns(listCtrl, {
		"ID",
		"Monster Name",
		"Behavior",
		"Use",
		"Level"
	})
	--]]
	lch.InitColumns(listCtrl, {
		{"ID",            45},
		{"Monster Name", 100},
		{"Behavior",      75},
		{"Use",           70},
		{"Level",         38}
	})
	
	--[[ -- DEBUG
	lch.InsertRow(listCtrl, {"77777", "Steel Chonchon", "avoid",       "slow_power",   "7"})
	lch.InsertRow(listCtrl, {"00000", "Wild Rose",      "coward",      "no_skill",   "500"})
	lch.InsertRow(listCtrl, {"00000", "Wild Rose",      "react_1st",   "one_skill",   "50"})
	lch.InsertRow(listCtrl, {"00000", "Wild Rose",      "react",       "two_skills",  "77"})
	lch.InsertRow(listCtrl, {"00000", "Wild Rose",      "react_last",  "max_skills", "999"})
	lch.InsertRow(listCtrl, {"00000", "Wild Rose",      "attack_1st",  "full_power", "666"})
	lch.InsertRow(listCtrl, {"00000", "Wild Rose",      "attack",      "slow_power", "777"})
	lch.InsertRow(listCtrl, {"00000", "Wild Rose",      "attack_last", "max_skills", "888"})
	lch.InsertRow(listCtrl, {"00000", "Wild Rose",      "attack_weak", "max_skills",   "5"})
	--]] -- END DEBUG
end


function M.LoadTactics(tactics, listCtrl)
	assert(type(tactics) == "table")
	assert(listCtrl)
	
	for i, v in ipairs(tactics) do
		assert(type(v) == "table" and #v == 6)
		local id, name, beha, use, level, aaa = v[1], v[2], v[3], v[4], v[5], v[6]
		if DEBUG then
			assert(type(id   ) == "number")
			assert(type(name ) == "string")
			assert(type(beha ) == "string")
			assert(type(use  ) == "string")
			assert(type(level) == "number")
			--assert(type(aaa  ) == "number") -- we don't need this
		end
		
		-- TODO: convert fields properly (numbers to string, cut BEHA_* and WITH_* prefixes)
		-- convert the fields before inserting them into the listCtrl:
		id = tostring(id)
		
		-- name stays as is
		
		assert(su.startsWith(beha, "BEHA_"))
		beha = beha:sub(6) -- cut off "BEHA_"
		
		assert(su.startsWith(use, "WITH_"))
		use = use:sub(6) -- cut off "WITH_"
		
		level = tostring(level)
		
		lch.InsertRow(listCtrl, {id, name, beha, use, level})
	end
end


function M.SaveTactics(f, listCtrl)
	assert(listCtrl)
	assert(f)
	
	f:write("Tact = {}\n")
	
	for i = 1, listCtrl:GetItemCount() do
		-- i-1 because the loop index is 1 based, but ReadRow is 0 based:
		local tact = lch.ReadRow(listCtrl, i-1)
		assert(#tact == 5)
		local id, name, beha, use, level = tact[1], tact[2], tact[3], tact[4], tact[5]
		
		-- id and name stay as they are
		beha = "BEHA_" .. beha
		use  = "WITH_" .. beha
		-- level stays as is
		
		local s 
		if su.startsWith(name, "--") then -- is this tactic a comment?
			s = name .. "\n"
		else
			s = string.format('Tact[%s] = {"%s", %s, %s, %s, 0}\n', id, name, beha, use, level)
		end
		
		DebugLog(s)
		f:write(s)
	end
	
	-- TODO: SaveTactics
end


return M
