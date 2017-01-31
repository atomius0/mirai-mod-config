-- mirai-mod-conf
-- TacticsTab functions

local AddTacticDialog = require "AddTacticDialog"
local lch = require "ListCtrlHelper"

local M = {}


-- OnEdit and OnAdd need the xmlResource parameter, because they create a new window using
-- AddTacticDialog from the xrc file.
function M.OnEdit(listCtrl, xmlResource)
	assert(listCtrl)
	assert(xmlResource)
	-- TODO: this
end


function M.OnAdd(listCtrl, xmlResource)
	assert(listCtrl)
	assert(xmlResource)
	
	AddTacticDialog(xmlResource, add) -- call constructor to show modal dialog
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


-- TODO: load and save functions


return M
