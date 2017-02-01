-- mirai-mod-conf
-- TacticsTab functions

local AddTacticDialog = require "AddTacticDialog"
local lch = require "ListCtrlHelper"
local su  = require "stringutil"

local M = {}


-- helper function: converts a tactic to a format suitable for the listCtrl
local function Tactic2ListCtrl(tactic)
	local t = tactic -- shorthand
	assert(type(t) == "table" and #t == 6)
	local id, name, beha, with, level, aaa = t[1], t[2], t[3], t[4], t[5], t[6]
	if DEBUG then
		assert(type(id   ) == "number")
		assert(type(name ) == "string")
		assert(type(beha ) == "string")
		assert(type(with ) == "string")
		assert(type(level) == "number")
		--assert(type(aaa  ) == "number") -- we don't need this
	end
	
	-- convert the fields into the listCtrl format:
	id = tostring(id)
	
	-- name stays as is
	
	assert(su.startsWith(beha, "BEHA_"))
	beha = beha:sub(6) -- cut off "BEHA_"
	
	assert(su.startsWith(with, "WITH_"))
	with = with:sub(6) -- cut off "WITH_"
	
	level = tostring(level)
	
	return {id, name, beha, with, level}
end

-- helper function: converts a tactic from the listCtrl format back to the regular tact format
local function ListCtrl2Tactic(tactic)
	local t = tactic -- shorthand
	assert(type(t) == "table" and #t == 5)
	local id, name, beha, with, level = t[1], t[2], t[3], t[4], t[5]
	
	id = tonumber(id)
	-- name stays as is
	beha  = "BEHA_" .. beha
	with  = "WITH_" .. with
	level = tonumber(level)
	
	return {id, name, beha, with, level, -1}
end


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
	---[[
	local tactic = AddTacticDialog(xmlResource, parent)
	
	if tactic then
		local selected = lch.GetFirstSelected(listCtrl)
		
		
		if selected then
			-- insert new tactic after the currently selected one:
			lch.InsertRow(listCtrl, selected+1, Tactic2ListCtrl(tactic))
			
		else -- if nothing was selected, add the tactic to the end of the list:
			lch.InsertRow(listCtrl, Tactic2ListCtrl(tactic))
		end
		
		
	end
	--]]
	--AddTacticDialog(xmlResource, parent, {1234, "Poring", "BEHA_coward", "WITH_slow_power", 4}) -- TODO: DEBUG!!
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
		lch.InsertRow(listCtrl, Tactic2ListCtrl(v))
	end
end


function M.SaveTactics(f, listCtrl)
	assert(listCtrl)
	assert(f)
	
	f:write("Tact = {}\n")
	
	for i = 1, listCtrl:GetItemCount() do
		-- i-1 because the loop index is 1 based, but ReadRow is 0 based:
		local t = ListCtrl2Tactic(lch.ReadRow(listCtrl, i-1))
		local id, name, beha, with, level, aaa = t[1], t[2], t[3], t[4], t[5], t[6]
		
		local s 
		if su.startsWith(name, "--") then -- is this tactic a comment?
			s = name .. "\n"
		else
			s = string.format(
				'Tact[%i] = {"%s", %s, %s, %i, %i}\n',
				id, name, beha, with, level, aaa
			)
		end
		
		DebugLog(s)
		f:write(s)
	end
	
	-- TODO: SaveTactics
end


return M
