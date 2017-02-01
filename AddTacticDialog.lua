-- mirai-mod-conf
-- class AddTacticDialog

local class = require "30log"

local AddTacticDialog = class("AddTacticDialog")

AddTacticDialog.IDs = {}

-- initializes AddTacticDialog, reads fields from table 'tactic' and inserts them into the widgets.
function AddTacticDialog:init(xmlResource, parent, tactic)
	assert(xmlResource)
	assert(parent)
	
	self.dialog = nil
	
	local handlers = {}
	
	function handlers.OnOK(event)
		DebugLog("AddTacticDialog: OnOK")
		event:Skip()
		
		
		-- TODO
	end
	
	
	function handlers.OnCancel(event)
		DebugLog("AddTacticDialog: OnCancel")
		event:Skip()
		-- TODO
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
	
	
	if tactic then -- was the 'tactic' parameter given?
		assert(type(tactic) == "table")
		
		-- fill the input fields with the values from table 'tactics':
		
		-- TODO: fill the input fields with the values from table 'tactics'
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
	if tactic then assert(type(tactic) == "table") end
	
	-- the dialog constructor needs the 'tactic' table to fill its widgets with the values from it.
	local dlg = AddTacticDialog(xmlResource, parent, tactic)
	
	assert(dlg.dialog)
	dlg.dialog:Center()
	local r = dlg.dialog:ShowModal()
	
	DebugLog("AddTacticDialog returned: " .. tostring(r))
	DebugLog("wx.wxID_OK = " .. wx.wxID_OK)
	DebugLog("wx.wxID_CANCEL = " .. wx.wxID_CANCEL)
	
	-- TODO: refactor this, we don't need variable 'r'
	-- TODO: parameter 'tactic' of AddTacticDialog constructor should not be optional!
	--       since we pass the tactic through it!
	
	if r == wx.wxID_OK then
		return tactic
	else -- wx.wxID_CANCEL
		return nil
	end
end
