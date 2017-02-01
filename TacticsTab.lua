-- mirai-mod-conf
-- TacticsTab functions

local AddTacticDialog = require "AddTacticDialog"
local lch = require "ListCtrlHelper"

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
	
	AddTacticDialog(xmlResource, parent)
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


function M.LoadTactics(listCtrl)
	assert(listCtrl)
	
	-- TODO: LoadTactics
end


function M.SaveTactics(listCtrl)
	assert(listCtrl)
	
	-- TODO: SaveTactics
end


return M
