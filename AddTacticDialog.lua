-- mirai-mod-conf
-- class AddTacticDialog

local class = require "30log"
local su    = require "stringutil"


local _BEHA_MAP = { -- used by helper functions BEHA2ID and ID2BEHA
	[0] = "BEHA_avoid",
	[1] = "BEHA_coward",
	[2] = "BEHA_react_1st",
	[3] = "BEHA_react",
	[4] = "BEHA_react_last",
	[5] = "BEHA_attack_1st",
	[6] = "BEHA_attack",
	[7] = "BEHA_attack_last",
	[8] = "BEHA_attack_weak"
}
local _WITH_MAP = { -- used by helper functions WITH2ID and ID2WITH
	[0] = "WITH_no_skill",
	[1] = "WITH_one_skill",
	[2] = "WITH_two_skills",
	[3] = "WITH_max_skills",
	[4] = "WITH_full_power",
	[5] = "WITH_slow_power"
}

-- helper functions for converting the IDs of the behavior and with/use skill wxChoice menus
-- to their tactic strings and back:
local function BEHA2ID(beha)
	for i = 0, #_BEHA_MAP do
		if _BEHA_MAP[i] == beha then return i end
	end
	return error("Unknown BEHA_* constant: " .. beha)
end


local function ID2BEHA(id)
	return _BEHA_MAP[id]
end


local function WITH2ID(with)
	for i = 0, #_WITH_MAP do
		if _WITH_MAP[i] == with then return i end
	end
	return error("Unknown WITH_* constant: " .. with)
end


local function ID2WITH(id)
	return _WITH_MAP[id]
end


local AddTacticDialog = class("AddTacticDialog")

AddTacticDialog.IDs = {}

-- initializes AddTacticDialog, reads fields from table 'tactic' and inserts them into the widgets.
function AddTacticDialog:init(xmlResource, parent, tactic)
	assert(xmlResource)
	assert(parent)
	assert(type(tactic) == "table")
	
	self.dialog = nil
	
	local handlers = {}
	
	function handlers.OnOK(event)
		DebugLog("AddTacticDialog: OnOK")
		event:Skip()
		
		local id, name, beha, with, level
		
		-- get values from input fields:
		id    = self.TC_ID:GetValue()
		name  = self.TC_MonsterName:GetValue()
		beha  = ID2BEHA(self.CHOICE_Behavior:GetSelection())
		with  = ID2WITH(self.CHOICE_SkillUse:GetSelection())
		level = self.CHOICE_Level:GetSelection() + 1 -- wxChoice selection indices start at 0, levels start at 1.
		
		
		-- check if inputs are valid:
		
		-- is 'name' a comment?
		if su.startsWith(name, "--") then
			if id ~= "" then -- id must be empty for comments
				wx.wxMessageBox("ID must be empty for comments", APP_NAME, wx.wxOK)
				event:Skip(false)
				
			elseif name == "-- End Tact" then
				-- this comment is recognized as the end of the tact list by 'LoadConfigOptions.lua'
				-- so it is not allowed:
				wx.wxMessageBox(
					string.format('Comment "%s" is not allowed!', name),
					APP_NAME, wx.wxOK
				)
				event:Skip(false)
			end
			-- set all values to default for comments:
			id    = 0
			beha  = "BEHA_avoid"
			with  = "WITH_no_skill"
			level = 1
			
			-- if 'name' is a comment, we don't need to check whether the id is valid.
		elseif id ~= tostring(tonumber(id)) then -- is 'id' a valid number?
			-- id is not a valid number (there are other characters in it?)
			wx.wxMessageBox("Invalid ID", APP_NAME, wx.wxOK)
			event:Skip(false) -- don't close this dialog
		end
		
		
		-- fill tactic table:
		tactic[1] = tonumber(id)
		tactic[2] = name
		tactic[3] = beha
		tactic[4] = with
		tactic[5] = level
		tactic[6] = -1 -- AAA, not supported
	end
	
	
	function handlers.OnCancel(event)
		DebugLog("AddTacticDialog: OnCancel")
		event:Skip()
		-- do nothing
	end
	
	
	-- check if ID table is not empty (so we don't add these IDs multiple times)
	-- (we do this here, but not in MainWindow, because the AddTacticDialog can be opened multiple
	--  times, but the MainWindow is opened only once, at program start.)
	if not next(AddTacticDialog.IDs) then
		-- get IDs / init wxWindow ID values:
		for i, v in ipairs {
			--"TXT_ID",
			"TC_ID",
			--"TXT_MonsterName",
			"TC_MonsterName",
			--"TXT_Behavior",
			"CHOICE_Behavior",
			--"TXT_SkillUse",
			"CHOICE_SkillUse",
			--"TXT_Level",
			"CHOICE_Level",
			
			"wxID_OK",
			"wxID_CANCEL"
		} do
			AddTacticDialog.IDs[v] = xmlResource.GetXRCID(v)
		end
	end
	
	
	-- load the dialog:
	self.dialog = wx.wxDialog()
	assert(xmlResource:LoadDialog(self.dialog, parent, "AddTacticDialog"),
		"Error loading dialog 'MainWindow'"
	)
	
	-- initialize the reference variables for the input fields:
	self:InitInputs()
	
	
	-- connect events to handler functions:
	
	self.dialog:Connect(AddTacticDialog.IDs.wxID_OK, wx.wxEVT_COMMAND_BUTTON_CLICKED, handlers.OnOK)
	self.dialog:Connect(AddTacticDialog.IDs.wxID_CANCEL, wx.wxEVT_COMMAND_BUTTON_CLICKED, handlers.OnCancel)
	
	
	if next(tactic) then -- if tactic table is not empty
		-- fill the input fields with the values from table 'tactic'
		
		local id, name, beha, with, level = tactic[1], tactic[2], tactic[3], tactic[4], tactic[5]
		
		-- if level was saved as 0, that would become selection ID -1, which would be invalid.
		if level <= 0 then level = 1 end
		local maxLevel = self.CHOICE_Level:GetCount()
		if level > maxLevel then level = maxLevel end
		
		if su.startsWith(name, "--") then
			-- leave the 'ID' textCtrl empty when the provided tactic is a comment
			self.TC_ID:SetValue("")
		else
			self.TC_ID:SetValue(tostring(id))
		end
		self.TC_MonsterName:SetValue(name)
		self.CHOICE_Behavior:SetSelection(BEHA2ID(beha))
		self.CHOICE_SkillUse:SetSelection(WITH2ID(with))
		self.CHOICE_Level:SetSelection(level - 1) -- selection ID starts a 0, level starts at 1.
		
	else -- if it is empty, fill it with default values:
		self.TC_ID:SetValue("")
		self.TC_MonsterName:SetValue("")
		self.CHOICE_Behavior:SetSelection(0)
		self.CHOICE_SkillUse:SetSelection(0)
		self.CHOICE_Level:SetSelection(0)
	end
	
	-- we won't show the dialog from this function:
	--self.dialog:Center()
	--self.dialog:Show(true)
end


function AddTacticDialog:InitInputs()
	
	local InitWidget = function(name, widgetType)
		DebugLog('InitWidget("' .. name .. '", "' .. widgetType .. '")')
		local w = assert(self.dialog:FindWindow(AddTacticDialog.IDs[name]))
		w = assert(w:DynamicCast(widgetType))
		self[name] = w
		--return w
	end
	
	InitWidget("TC_ID", "wxTextCtrl")
	InitWidget("TC_MonsterName", "wxTextCtrl")
	InitWidget("CHOICE_Behavior", "wxChoice")
	InitWidget("CHOICE_SkillUse", "wxChoice")
	InitWidget("CHOICE_Level", "wxChoice")
end


-- we won't return the class here!
--return AddTacticDialog

-- instead, we return a function 'ShowAddTacticDialog',
-- which opens a modal dialog and returns the new (or modified) tactic as a table
-- returns nil if user clicked cancel.
return function(xmlResource, parent, tactic) -- function ShowAddTacticDialog(xmlResource, tactic)
	assert(xmlResource)
	assert(parent)
	tactic = tactic or {}
	
	-- the dialog constructor needs the 'tactic' table to fill its widgets with the values from it.
	local dlg = AddTacticDialog(xmlResource, parent, tactic)
	
	assert(dlg.dialog)
	dlg.dialog:Center()
	local r = dlg.dialog:ShowModal()
	
	if DEBUG then
		DebugLog("AddTacticDialog returned: " .. tostring(r))
		DebugLog("wx.wxID_OK = " .. wx.wxID_OK)
		DebugLog("wx.wxID_CANCEL = " .. wx.wxID_CANCEL)
		
		DebugLog("tactic:")
		for i,v in ipairs(tactic) do
			print(i, v)
		end
		DebugLog("end tactic")
	end
	
	if r == wx.wxID_OK then
		return tactic
	else -- wx.wxID_CANCEL
		return nil
	end
end
