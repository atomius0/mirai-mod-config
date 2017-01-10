-- mirai-mod-conf
-- class MainWindow

local class = require "30log"

local MainWindow = class("MainWindow")

MainWindow.IDs = {}


function MainWindow:init(xmlResource)
	assert(xmlResource)
	-- no parent parameter for this function,
	-- since we will only ever have one instance of MainWindow
	
	-- TODO: keep a reference to xmlResource?
	--       we might need it when MainWindow wants to create a child window.
	
	self.dialog = nil
	-- TODO: self.* reference variables for the remaining input fields (eg. wxSlider, wxSpinCtrl, wxListBox)
	self.SL_AttackWhenHP = nil
	self.SC_AttackWhenHP = nil
	self.SL_EvadeWhenHP  = nil
	self.SC_EvadeWhenHP  = nil
	
	local handlers = {} -- table for all event handler functions
	
	function handlers.OnClose(event)
		DebugLog("MainWindow: OnClose")
		event:Skip()
		-- TODO: check if there are unsaved changes and warn user before quitting.
		self.dialog:Show(false)
		self.dialog:Destroy()
		-- for some reason, the standalone exe process does not always end
		-- when MainWindow is closed (or does it?)
		-- so we force it to end:
		os.exit()
	end
	
	-- manages linking of "Homunculus: Attack and Evade" sliders and spinCtrls (tab "General")
	function handlers.OnAttackAndEvade(event)
		DebugLog("MainWindow: OnAttackAndEvade")
		event:Skip()
		
		local attackChanged = false
		local evadeChanged = false
		
		local src = event:GetId()
		if src == MainWindow.IDs.SL_AttackWhenHP then
			DebugLog("source: SL_AttackWhenHP")
			self.SC_AttackWhenHP:SetValue(event:GetInt())
			attackChanged = true
			
		elseif src == MainWindow.IDs.SC_AttackWhenHP then
			DebugLog("source: SC_AttackWhenHP")
			self.SL_AttackWhenHP:SetValue(event:GetInt())
			attackChanged = true
			
		elseif src == MainWindow.IDs.SL_EvadeWhenHP then
			DebugLog("source: SL_EvadeWhenHP")
			self.SC_EvadeWhenHP:SetValue(event:GetInt())
			evadeChanged = true
			
		elseif src == MainWindow.IDs.SC_EvadeWhenHP then
			DebugLog("source: SC_EvadeWhenHP")
			self.SL_EvadeWhenHP:SetValue(event:GetInt())
			evadeChanged = true
		end
		
		local attack = self.SC_AttackWhenHP:GetValue()
		local evade = self.SC_EvadeWhenHP:GetValue()
		if attackChanged and attack < evade then
			DebugLog("attackChanged and attack < evade")
			self.SC_EvadeWhenHP:SetValue(attack)
			self.SL_EvadeWhenHP:SetValue(attack)
			
		elseif evadeChanged and evade > attack then
			DebugLog("evadeChanged and evade > attack")
			self.SC_AttackWhenHP:SetValue(evade)
			self.SL_AttackWhenHP:SetValue(evade)
		end
	end
	
	-- TODO: remaining event handler functions, eg: "function handlers.OnSomething(event)"
	
	
	-- get IDs / init wxWindow ID values (yes, before loading the dialog)
	-- TODO: add all the remaining IDs!
	for i, v in ipairs {
		"SL_AttackWhenHP",
		"SC_AttackWhenHP",
		"SL_EvadeWhenHP",
		"SC_EvadeWhenHP"
	} do
		MainWindow.IDs[v] = xmlResource.GetXRCID(v)
	end
	
	
	-- load the dialog:
	self.dialog = wx.wxDialog()
	assert(xmlResource:LoadDialog(self.dialog, wx.NULL, "MainWindow"), 
		"Error loading dialog 'MainWindow'"
	)
	
	
	-- initialize the reference variables for the input fields:
	self.SL_AttackWhenHP = assert(self.dialog:FindWindow(MainWindow.IDs.SL_AttackWhenHP))
	self.SL_AttackWhenHP = assert(self.SL_AttackWhenHP:DynamicCast("wxSlider"))
	
	self.SC_AttackWhenHP = assert(self.dialog:FindWindow(MainWindow.IDs.SC_AttackWhenHP))
	self.SC_AttackWhenHP = assert(self.SC_AttackWhenHP:DynamicCast("wxSpinCtrl"))
	
	self.SL_EvadeWhenHP = assert(self.dialog:FindWindow(MainWindow.IDs.SL_EvadeWhenHP))
	self.SL_EvadeWhenHP = assert(self.SL_EvadeWhenHP:DynamicCast("wxSlider"))
	
	self.SC_EvadeWhenHP = assert(self.dialog:FindWindow(MainWindow.IDs.SC_EvadeWhenHP))
	self.SC_EvadeWhenHP = assert(self.SC_EvadeWhenHP:DynamicCast("wxSpinCtrl"))
	
	-- TODO: initialize the remaining reference variables for all the input fields
	
	
	-- connect events to handler functions:
	
	-- (see wxWidgets docs: class "wxCommandEvent")
	self.dialog:Connect(MainWindow.IDs.SL_AttackWhenHP, wx.wxEVT_COMMAND_SLIDER_UPDATED, handlers.OnAttackAndEvade)
	-- found the wxEVT_* constant via wxLua sample program "controls.wx.lua"
	self.dialog:Connect(MainWindow.IDs.SC_AttackWhenHP, wx.wxEVT_COMMAND_SPINCTRL_UPDATED, handlers.OnAttackAndEvade)
	
	self.dialog:Connect(MainWindow.IDs.SL_EvadeWhenHP, wx.wxEVT_COMMAND_SLIDER_UPDATED, handlers.OnAttackAndEvade)
	self.dialog:Connect(MainWindow.IDs.SC_EvadeWhenHP, wx.wxEVT_COMMAND_SPINCTRL_UPDATED, handlers.OnAttackAndEvade)
	
	-- TODO: connect remaining events to handler functions
	
	-- connect the closeevent to the OnClose function:
	self.dialog:Connect(wx.wxEVT_CLOSE_WINDOW, handlers.OnClose)
	
	--TODO: load Config.lua? (and if it doesn't exist, create it)
	
	
	self:HideLanguageTab(xmlResource) -- TODO: remove this later
	
	self.dialog:Center()
	self.dialog:Show(true)
end


-- TEMP: hide the tab "Language" / TODO: remove this later
function MainWindow:HideLanguageTab(xmlResource)
	--[[
	local TAB_Language_ID = xmlResource.GetXRCID("TAB_Language")
	local TAB_Language = assert(self.dialog:FindWindow(xmlResource.GetXRCID("TAB_Language")))
	TAB_Language:Show(false)
	--]]
	local nb = assert(self.dialog:FindWindow(xmlResource.GetXRCID("m_notebook1")))
	nb = assert(nb:DynamicCast("wxNotebook"))
	nb:DeletePage(4)
end


return MainWindow
