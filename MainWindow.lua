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
		"CB_DontMove",
		"SL_AttackWhenHP",
		"SC_AttackWhenHP",
		"SL_EvadeWhenHP",
		"SC_EvadeWhenHP",
		
		"CB_HelpOwnerFirst",
		"CB_KillEnemiesFirst",
		"CB_NoMovingTargets",
		"CB_AdvMotionCheck",
		
		"CB_FollowAtOnce",
		"CB_CircleOnIdle",
		
		"SC_MaxEnemyDistance",
		"SC_SkillTimeout",
		"SC_OwnerClosedistance",
		
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
	
	-- load the configuration file before showing the window:
	self:LoadConfig(CONFIG_FILE)
	
	self.dialog:Center()
	self.dialog:Show(true)
end


-- initializes the reference variables for the input fields
function MainWindow:InitInputs()
	
	local InitWidget = function(name, widgetType)
		DebugLog('InitWidget("' .. name .. '", "' .. widgetType .. '")')
		local w = assert(self.dialog:FindWindow(MainWindow.IDs[name]))
		w = assert(w:DynamicCast(widgetType))
		self[name] = w
		--return w
	end
	
	
	InitWidget("CB_DontMove", "wxCheckBox")
	
	-- the 4 input references
	-- "SL_AttackWhenHP", "SC_AttackWhenHP", "SL_EvadeWhenHP" and "SC_EvadeWhenHP"
	-- are also used by function 'handlers.OnAttackAndEvade'
	InitWidget("SL_AttackWhenHP", "wxSlider")
	InitWidget("SC_AttackWhenHP", "wxSpinCtrl")
	InitWidget("SL_EvadeWhenHP", "wxSlider")
	InitWidget("SC_EvadeWhenHP", "wxSpinCtrl")
	
	
	-- the input references below are only used by MainWindow:SaveConfig and MainWindow:LoadConfig
	InitWidget("CB_HelpOwnerFirst", "wxCheckBox")
	InitWidget("CB_KillEnemiesFirst", "wxCheckBox")
	InitWidget("CB_NoMovingTargets", "wxCheckBox")
	InitWidget("CB_AdvMotionCheck", "wxCheckBox")
	
	-- TODO: more stuff
	InitWidget("SC_MaxEnemyDistance", "wxSpinCtrl")
	InitWidget("SC_SkillTimeout", "wxSpinCtrl")
	InitWidget("SC_OwnerClosedistance", "wxSpinCtrl")
	
	InitWidget("CB_FollowAtOnce", "wxCheckBox")
	InitWidget("CB_CircleOnIdle", "wxCheckBox")
	
	
	-- TODO: more stuff
	
	-- TODO: initialize the remaining reference variables for all the input fields
end

-- saves the configuration to file 'filename'
function MainWindow:SaveConfig(filename)
	assert(type(filename) == "string")
	DebugLog('MainWindow:SaveConfig("' .. filename .. '")')
	
	-- TODO: add error handler (try/catch block) to all functions that call this one!
	local f = assert(io.open(filename, "w"))
	
	local WriteOpt = function(o) DebugLog(o); f:write(o .. "\n") end
	
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
	WriteOpt("KILL_YOUR_ENEMIES_1ST=" .. tostring(self.CB_KillEnemiesFirst:GetValue()))
	WriteOpt("LONG_RANGE_SHOOTER=" .. tostring(self.CB_DontMove:GetValue()))
	
	-- BOLTS_ON_CHASE_ST is not supported by mirai-mod-config
	WriteOpt(
		"BOLTS_ON_CHASE_ST=false -- part of 'Alchemist Auto Attacks', not supported by " .. APP_NAME
	)
	WriteOpt("HP_PERC_DANGER=" .. tostring(self.SC_EvadeWhenHP:GetValue()))
	WriteOpt("HP_PERC_SAFE2ATK=" .. tostring(self.SC_AttackWhenHP:GetValue()))
	WriteOpt("OWNER_CLOSEDISTANCE=" .. tostring(self.SC_OwnerClosedistance:GetValue()))
	WriteOpt("TOO_FAR_TARGET=" .. tostring(self.SC_MaxEnemyDistance:GetValue()))
	WriteOpt("SKILL_TIME_OUT=" .. tostring(self.SC_SkillTimeout:GetValue()))
	WriteOpt("NO_MOVING_TARGETS=" .. tostring(self.CB_NoMovingTargets:GetValue()))
	
	WriteOpt("ADV_MOTION_CHECK=" .. tostring(self.CB_AdvMotionCheck:GetValue()))
	
	-- TODO: this (SaveConfig) !!!!!!!!!!!!!!!!!!!!!!!
	
	-- TODO: save the auto attack stuff (with a comment that it is disabled and not configurable)
	
	-- TODO: save regular settings
	-- TODO: save skill settings
	-- TODO: save selected Mod
	-- TODO: save tactics
	-- TODO: Checkbox "Cautious" / Option "DEFAULT_BEHA" and "DEFAULT_WITH" come right before the Tact list!
	
	f:close()
end


-- loads the configuration from file 'filename'
function MainWindow:LoadConfig(filename)
	assert(type(filename) == "string")
	DebugLog('MainWindow:LoadConfig("' .. filename .. '")')
	
	-- TODO: add error handler (try/catch block) to all functions that call this one!
	
	local f = io.open(filename, "r")
	if not f then
		--DebugLog("Configuration file could not be opened, creating new file...")
		--self:SaveConfig(filename)
		DebugLog("Configuration file could not be opened, using default settings.")
		return
	end
	
	
	
	-- TODO: LoadConfig!
	
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
