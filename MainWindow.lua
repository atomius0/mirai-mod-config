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
	
	self.CB_CircleOnIdle = nil
	
	--self.BUT_SaveConfig = nil
	
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
	
	
	function handlers.OnSaveConfig(event)
		DebugLog("MainWindow: OnSaveConfig")
		event:Skip()
		self:SaveConfig(CONFIG_FILE)
	end
	
	-- TODO: remaining event handler functions, eg: "function handlers.OnSomething(event)"
	
	
	-- get IDs / init wxWindow ID values (yes, before loading the dialog)
	-- TODO: add all the remaining IDs!
	for i, v in ipairs {
		"SL_AttackWhenHP",
		"SC_AttackWhenHP",
		"SL_EvadeWhenHP",
		"SC_EvadeWhenHP",
		
		"CB_HelpOwnerFirst",
		
		"CB_FollowAtOnce",
		"CB_CircleOnIdle",
		
		"BUT_SaveConfig",
	} do
		MainWindow.IDs[v] = xmlResource.GetXRCID(v)
	end
	
	
	-- load the dialog:
	self.dialog = wx.wxDialog()
	assert(xmlResource:LoadDialog(self.dialog, wx.NULL, "MainWindow"), 
		"Error loading dialog 'MainWindow'"
	)
	
	
	-- initialize the reference variables for the input fields:
	self:InitInputs()
	
	
	-- connect events to handler functions:
	
	-- (see wxWidgets docs: class "wxCommandEvent")
	self.dialog:Connect(MainWindow.IDs.SL_AttackWhenHP, wx.wxEVT_COMMAND_SLIDER_UPDATED, handlers.OnAttackAndEvade)
	-- found the wxEVT_* constant via wxLua sample program "controls.wx.lua"
	self.dialog:Connect(MainWindow.IDs.SC_AttackWhenHP, wx.wxEVT_COMMAND_SPINCTRL_UPDATED, handlers.OnAttackAndEvade)
	
	self.dialog:Connect(MainWindow.IDs.SL_EvadeWhenHP, wx.wxEVT_COMMAND_SLIDER_UPDATED, handlers.OnAttackAndEvade)
	self.dialog:Connect(MainWindow.IDs.SC_EvadeWhenHP, wx.wxEVT_COMMAND_SPINCTRL_UPDATED, handlers.OnAttackAndEvade)
	
	self.dialog:Connect(MainWindow.IDs.BUT_SaveConfig, wx.wxEVT_COMMAND_BUTTON_CLICKED, handlers.OnSaveConfig)
	-- TODO: connect remaining events to handler functions
	
	-- connect the closeevent to the OnClose function:
	self.dialog:Connect(wx.wxEVT_CLOSE_WINDOW, handlers.OnClose)
	
	--TODO: load Config.lua? (and if it doesn't exist, create it)
	
	
	self:HideLanguageTab(xmlResource) -- TODO: remove this later
	
	local skills = {
		{"Amistr", {
			{"Bulwark", 5, "hami_defence.gif"}
		}}
	}
	FillSkillsTab(self.dialog, xmlResource, skills)
	
	self.dialog:Center()
	self.dialog:Show(true)
end


-- initializes the reference variables for the input fields
function MainWindow:InitInputs()
	-- these 4 input references are also used by function 'handlers.OnAttackAndEvade'
	self.SL_AttackWhenHP = assert(self.dialog:FindWindow(MainWindow.IDs.SL_AttackWhenHP))
	self.SL_AttackWhenHP = assert(self.SL_AttackWhenHP:DynamicCast("wxSlider"))
	
	self.SC_AttackWhenHP = assert(self.dialog:FindWindow(MainWindow.IDs.SC_AttackWhenHP))
	self.SC_AttackWhenHP = assert(self.SC_AttackWhenHP:DynamicCast("wxSpinCtrl"))
	
	self.SL_EvadeWhenHP = assert(self.dialog:FindWindow(MainWindow.IDs.SL_EvadeWhenHP))
	self.SL_EvadeWhenHP = assert(self.SL_EvadeWhenHP:DynamicCast("wxSlider"))
	
	self.SC_EvadeWhenHP = assert(self.dialog:FindWindow(MainWindow.IDs.SC_EvadeWhenHP))
	self.SC_EvadeWhenHP = assert(self.SC_EvadeWhenHP:DynamicCast("wxSpinCtrl"))
	
	
	-- the input references below are only used by MainWindow:SaveConfig and MainWindow:LoadConfig
	self.CB_HelpOwnerFirst = assert(self.dialog:FindWindow(MainWindow.IDs.CB_HelpOwnerFirst))
	self.CB_HelpOwnerFirst = assert(self.CB_HelpOwnerFirst:DynamicCast("wxCheckBox"))
	
	-- TODO: more stuff
	
	self.CB_FollowAtOnce = assert(self.dialog:FindWindow(MainWindow.IDs.CB_FollowAtOnce))
	self.CB_FollowAtOnce = assert(self.CB_FollowAtOnce:DynamicCast("wxCheckBox"))
	
	self.CB_CircleOnIdle = assert(self.dialog:FindWindow(MainWindow.IDs.CB_CircleOnIdle))
	self.CB_CircleOnIdle = assert(self.CB_CircleOnIdle:DynamicCast("wxCheckBox"))
	
	-- TODO: more stuff
	
	-- TODO: initialize the remaining reference variables for all the input fields
end

-- saves the configuration to file 'filename'
function MainWindow:SaveConfig(filename)
	assert(type(filename) == "string")
	DebugLog('MainWindow:SaveConfig("' .. filename .. '")')
	
	-- TODO: add error handler (try/catch block) to all functions that call this one!
	local f = assert(io.open(filename, "w"))
	
	local WriteOpt = function(o) DebugLog(o); f:write(o) end
	
	-- write header:
	f:write(
		"--------------------------------------------------\n" ..
		"-- Mir AI configuration file (generated by " .. APP_NAME .. ")\n" ..
		"--------------------------------------------------\n"
	)
	
	-- save regular settings:
	
	-- TAB_General:
	WriteOpt("CIRCLE_ON_IDLE=" .. tostring(self.CB_CircleOnIdle:GetValue() and 1 or 0))
	WriteOpt("FOLLOW_AT_ONCE=" .. tostring(self.CB_FollowAtOnce:GetValue() and 1 or 0))
	WriteOpt("HELP_OWNER_1ST=" .. tostring(self.CB_HelpOwnerFirst:GetValue()))
	
	-- TODO: this (SaveConfig) !!!!!!!!!!!!!!!!!!!!!!!
	
	-- TODO: save the auto attack stuff (with a comment that it is disabled and not configurable)
	
	-- TODO: save regular settings
	-- TODO: save skill settings
	-- TODO: save selected Mod
	-- TODO: save tactics
	
	f:close()
end


function FillSkillsTab(dialog, xmlResource, skills) -- returns table with references to all widgets
	assert(type(skills) == "table")
	
	-- constants for the "minimum SP for skill use" spinCtrl:
	local SKILL_MINSP, SKILL_MAXSP = 0, 999999
	
	-- skills is a list of tables with the format:
	-- skills[1] = {homu_name, SKILL_LIST}
	-- where SKILL_LIST is a list of tables with the format:
	-- SKILL_LIST[1] = {skill_name, skill_maxlvl, skill_icon}
	
	local SCROLLWIN_Skills = assert(dialog:FindWindow(xmlResource.GetXRCID("SCROLLWIN_Skills")))
	local BSIZER_Skills = assert(SCROLLWIN_Skills:GetSizer())
	
	local TXT_SkillsDescription = wx.wxStaticText(SCROLLWIN_Skills, wx.wxID_ANY,
		"Please choose the minimum amount of SP for each skill and\nthe " ..
		"skill level to use (OFF = skill disabled).", wx.wxDefaultPosition, wx.wxDefaultSize, 0
	)
	TXT_SkillsDescription:Wrap(-1)
	BSIZER_Skills:Add(TXT_SkillsDescription, 0, wx.wxALL, 5)
	
	local widgets = {}
	widgets.TXT_SkillsDescription = TXT_SkillsDescription -- for translation
	
	-- TODO: this (FillSkillsTab)
	
end


-- TEMP: hide the tab "Language" / TODO: remove this later
function MainWindow:HideLanguageTab(xmlResource)
	local nb = assert(self.dialog:FindWindow(xmlResource.GetXRCID("m_notebook1")))
	nb = assert(nb:DynamicCast("wxNotebook"))
	nb:DeletePage(4)
end


return MainWindow
