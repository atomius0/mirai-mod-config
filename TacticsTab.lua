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
		{"ID",           60},
		{"Monster Name", 85},
		{"Behavior",     20}, -- TODO: widths
		{"Use",          20},
		{"Level",        20}
	})
end

-- TODO: load and save functions


return M
