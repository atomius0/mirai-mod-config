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
	
	-- check if a tactic is selected, if not: show MessageBox
	local selected = lch.GetFirstSelected(listCtrl)
	
	if not selected then
		return wx.wxMessageBox("Select a tactic to edit!", APP_NAME, wx.wxOK)
	end
	
	-- read tactic from listCtrl
	local tactic = ListCtrl2Tactic(lch.ReadRow(listCtrl, selected))
	
	-- call AddTacticDialog
	local newTactic = AddTacticDialog(xmlResource, parent, tactic)
	
	-- if AddTacticDialog returned a tactic, insert it, replacing the old one:
	if newTactic then
		lch.ReplaceRow(listCtrl, selected, Tactic2ListCtrl(tactic))
	end
end


function M.OnAdd(listCtrl, xmlResource, parent)
	assert(listCtrl)
	assert(xmlResource)
	assert(parent)
	
	local tactic = AddTacticDialog(xmlResource, parent)
	
	if tactic then
		local selected = lch.GetFirstSelected(listCtrl)
		
		local newItemPos -- position of the newly added item. needed to select the new item.
		
		if selected then
			-- insert new tactic after the currently selected one:
			newItemPos = lch.InsertRow(listCtrl, selected+1, Tactic2ListCtrl(tactic))
			
		else -- if nothing was selected, add the tactic to the end of the list:
			newItemPos = lch.InsertRow(listCtrl, Tactic2ListCtrl(tactic))
		end
		
		lch.SelectRow(listCtrl, newItemPos)
	end
end


function M.OnRemove(listCtrl)
	assert(listCtrl)
	
	local selected = lch.GetFirstSelected(listCtrl)
	
	if not selected then
		return wx.wxMessageBox("Select a tactic to remove!", APP_NAME, wx.wxOK)
	end
	
	lch.DeleteRow(listCtrl, selected)
	
	
	-- get the smaller index of either:
	-- -- the position where the deleted row was,
	-- or: 
	-- -- the last item in the list
	
	-- MARK: uncomment the line below if nothing should be selected after deleting the last list element:
	selected = math.min(selected, listCtrl:GetItemCount()-1)
	
	-- after deleting a row, select the next one:
	lch.SelectRow(listCtrl, selected)
end


function M.OnUp(listCtrl)
	assert(listCtrl)
	
	local selected = lch.GetFirstSelected(listCtrl)
	
	if selected and selected > 0 then
		lch.SwapRows(listCtrl, selected, selected-1)
		lch.SelectRow(listCtrl, selected-1) -- select the row that was moved
	end
end


function M.OnDown(listCtrl)
	assert(listCtrl)
	
	local selected = lch.GetFirstSelected(listCtrl)
	
	if selected and selected < listCtrl:GetItemCount()-1 then
		lch.SwapRows(listCtrl, selected, selected+1)
		lch.SelectRow(listCtrl, selected+1) -- select the row that was moved
	end
end


function M.Init(listCtrl)
	assert(listCtrl)
	
	--[[ -- no widths specified
	lch.InitColumns(listCtrl, {
		"ID",
		"Monster Name",
		"Behavior",
		"Use",
		"Level"
	})
	--]]
	---[[ -- with widths
	lch.InitColumns(listCtrl, {
		{"ID",            45},
		{"Monster Name", 100},
		{"Behavior",      75},
		{"Use",           70},
		{"Level",         38}
	})
	--]]
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
	
	f:write("-- End Tact\n")
end


return M
