-- mirai-mod-conf
-- class MainWindow

local class             = require "30log"
local LoadConfigOptions = require "LoadConfigOptions"
local SkillsTab         = require "SkillsTab"
local TacticsTab        = require "TacticsTab"
local ModTab            = require "ModTab"
local LanguageTab       = require "LanguageTab"
local _T                = require "TranslationLoader"

local _OLD_HOMUN_TYPE_MAP = { -- used by helper functions OLD_HOMUN_TYPE2ID and ID2OLD_HOMUN_TYPE
	[0] = "LIF",
	[1] = "FILIR",
	[2] = "AMISTR",
	[3] = "VANILMIRTH",
}

-- helper functions for converting the IDs of the OLD_HOMUN_TYPE wxChoice menu
-- to their constants and back:
local function OLD_HOMUN_TYPE2ID(oht)
	for i = 0, #_OLD_HOMUN_TYPE_MAP do
		if _OLD_HOMUN_TYPE_MAP[i] == oht then return i end
	end
	return error("Unknown OLD_HOMUN_TYPE constant: " .. oht)
end


local function ID2OLD_HOMUN_TYPE(id)
	return _OLD_HOMUN_TYPE_MAP[id]
end



local MainWindow = class("MainWindow")

MainWindow.IDs = {}


function MainWindow:init(xmlResource)
	assert(xmlResource)
	-- no parent parameter for this function,
	-- since we will only ever have one instance of MainWindow
	
	self.dialog = nil
	
	local handlers = {} -- table for all event handler functions
	
	function handlers.OnClose(event)
		DebugLog("MainWindow: OnClose")
		event:Skip()
		
		-- ask user if he wants to save before quitting:
		local r = wx.wxMessageBox(
			_T"Save changes before Quitting?",
			_T"Save?",
			wx.wxYES_NO + wx.wxCANCEL,
			self.dialog
		)
		if r == wx.wxYES then -- save settings and quit
			DebugLog("YES")
			xpcall(function()
				self:SaveConfig(CONFIG_FILE)
			end, ErrorHandler)
			-- fall through
			
		elseif r == wx.wxNO then -- quit without saving
			DebugLog("NO")
			-- fall through
			
		elseif r == wx.wxCANCEL then -- cancel: don't save, don't quit
			DebugLog("CANCEL")
			event:Skip(false) -- don't accept the close event
			return -- return without quitting
		end
		
		
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
	
	
	function handlers.OnButtonEdit(event)
		DebugLog("MainWindow: OnButtonEdit")
		event:Skip()
		TacticsTab.OnEdit(self.LC_Tactics, xmlResource, self.dialog)
	end
	
	
	function handlers.OnButtonAdd(event)
		DebugLog("MainWindow: OnButtonAdd")
		event:Skip()
		TacticsTab.OnAdd(self.LC_Tactics, xmlResource, self.dialog)
	end
	
	
	function handlers.OnButtonRemove(event)
		DebugLog("MainWindow: OnButtonRemove")
		event:Skip()
		TacticsTab.OnRemove(self.LC_Tactics)
	end
	
	
	function handlers.OnButtonUp(event)
		DebugLog("MainWindow: OnButtonUp")
		event:Skip()
		TacticsTab.OnUp(self.LC_Tactics)
	end
	
	
	function handlers.OnButtonDown(event)
		DebugLog("MainWindow: OnButtonDown")
		event:Skip()
		TacticsTab.OnDown(self.LC_Tactics)
	end
	
	
	function handlers.OnSaveConfig(event)
		DebugLog("MainWindow: OnSaveConfig")
		event:Skip()
		
		xpcall(function()
			self:SaveConfig(CONFIG_FILE)
		end, ErrorHandler)
	end
	
	-- TODO: remaining event handler functions, eg: "function handlers.OnSomething(event)"
	
	
	-- get IDs / init wxWindow ID values (yes, before loading the dialog)
	for i, v in ipairs {
		"NB_Notebook",
		--"TAB_General", -- Tab 'General' ----------------------------------------------------------
		"HNDL_HomuAttackAndEvade",
		"TXT_AttackWhenHP",
		"CB_DontMove",
		"SL_AttackWhenHP",
		"SC_AttackWhenHP",
		"TXT_EvadeWhenHP",
		"CB_Cautious",
		"SL_EvadeWhenHP",
		"SC_EvadeWhenHP",
		"CB_HelpOwnerFirst",
		"CB_KillEnemiesFirst",
		
		"HNDL_KindHomu",
		"CB_NoMovingTargets",
		"CB_AdvMotionCheck",
		
		"HNDL_Other",
		"TXT_MaxEnemyDistance",
		"SC_MaxEnemyDistance",
		"TXT_SkillTimeout",
		"SC_SkillTimeout",
		"TXT_OwnerClosedistance",
		"SC_OwnerClosedistance",
		"TXT_OldHomunType",
		"CHOICE_OldHomunType",
		"CB_FollowAtOnce",
		"CB_CircleOnIdle",
		
		
		--"TAB_Tactics", -- Tab 'Tactics' ----------------------------------------------------------
		"BUT_Edit",
		"BUT_Add",
		"BUT_Remove",
		"BUT_Up",
		"BUT_Down",
		"LC_Tactics",
		
		
		--"TAB_Skills", -- Tab 'Skills' ------------------------------------------------------------
		--"SCROLLWIN_Skills", -- we don't need this, SkillsTab.lua manages this by itself.
		
		
		--"TAB_Mod", -- Tab 'Mod' ------------------------------------------------------------------
		"LB_Mod",
		
		
		--"TAB_Language", -- Tab 'Language' --------------------------------------------------------
		"LB_Language",
		
		
		"BUT_SaveConfig",
		"TXT_Version",
	} do
		MainWindow.IDs[v] = xmlResource.GetXRCID(v)
	end
	
	
	-- load the dialog:
	self.dialog = wx.wxDialog()
	assert(xmlResource:LoadDialog(self.dialog, wx.NULL, "MainWindow"), 
		string.format(_T"Error loading dialog '%s'", "MainWindow")
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
	
	self.dialog:Connect(MainWindow.IDs.BUT_Edit, wx.wxEVT_COMMAND_BUTTON_CLICKED, handlers.OnButtonEdit)
	self.dialog:Connect(MainWindow.IDs.BUT_Add, wx.wxEVT_COMMAND_BUTTON_CLICKED, handlers.OnButtonAdd)
	self.dialog:Connect(MainWindow.IDs.BUT_Remove, wx.wxEVT_COMMAND_BUTTON_CLICKED, handlers.OnButtonRemove)
	self.dialog:Connect(MainWindow.IDs.BUT_Up, wx.wxEVT_COMMAND_BUTTON_CLICKED, handlers.OnButtonUp)
	self.dialog:Connect(MainWindow.IDs.BUT_Down, wx.wxEVT_COMMAND_BUTTON_CLICKED, handlers.OnButtonDown)
	
	self.dialog:Connect(MainWindow.IDs.BUT_SaveConfig, wx.wxEVT_COMMAND_BUTTON_CLICKED, handlers.OnSaveConfig)
	
	-- connect the closeevent to the OnClose function:
	self.dialog:Connect(wx.wxEVT_CLOSE_WINDOW, handlers.OnClose)
	
	
	-- SkillsTab.FillSkillsTab returns a a table containing references to the widgets it creates
	self.skillWidgets = SkillsTab.FillSkillsTab(self.dialog, xmlResource)
	
	-- Initialize the TacticsTab:
	TacticsTab.Init(self.LC_Tactics)
	
	-- Initialize the ModTab:
	ModTab.Init(self.LB_Mod)
	
	-- Initialize the LanguageTab:
	LanguageTab.Init(self.LB_Language, TRANSLATION_PATH)
	
	
	-- load the configuration file before showing the window:
	self:LoadConfig(CONFIG_FILE)
	
	-- Set the version number staticText:
	self.TXT_Version:SetLabel(APP_VERSION)
	
	--self:HideLanguageTab(xmlResource) -- TODO: remove this later
	
	self:ApplyTranslation()
	
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
	
	InitWidget("NB_Notebook", "wxNotebook")
	
	-- hidden widget used to get a handle of the containing wxStaticBoxSizer:
	InitWidget("HNDL_HomuAttackAndEvade", "wxWindow") -- actually a wxStaticText, but wxWindow is enough
	InitWidget("TXT_AttackWhenHP", "wxStaticText")
	InitWidget("CB_DontMove", "wxCheckBox")
	
	-- the 4 input references
	-- "SL_AttackWhenHP", "SC_AttackWhenHP", "SL_EvadeWhenHP" and "SC_EvadeWhenHP"
	-- are also used by function 'handlers.OnAttackAndEvade'
	InitWidget("SL_AttackWhenHP", "wxSlider")
	InitWidget("SC_AttackWhenHP", "wxSpinCtrl")
	
	InitWidget("TXT_EvadeWhenHP", "wxStaticText")
	InitWidget("CB_Cautious", "wxCheckBox")
	InitWidget("SL_EvadeWhenHP", "wxSlider")
	InitWidget("SC_EvadeWhenHP", "wxSpinCtrl")
	
	-- the input references below are only used by MainWindow:SaveConfig and MainWindow:LoadConfig
	InitWidget("CB_HelpOwnerFirst", "wxCheckBox")
	InitWidget("CB_KillEnemiesFirst", "wxCheckBox")
	
	InitWidget("HNDL_KindHomu", "wxWindow") -- hidden widget for wxStaticBoxSizer handle
	InitWidget("CB_NoMovingTargets", "wxCheckBox")
	InitWidget("CB_AdvMotionCheck", "wxCheckBox")
	
	InitWidget("HNDL_Other", "wxWindow") -- hidden widget for wxStaticBoxSizer handle
	InitWidget("TXT_MaxEnemyDistance", "wxStaticText")
	InitWidget("SC_MaxEnemyDistance", "wxSpinCtrl")
	InitWidget("TXT_SkillTimeout", "wxStaticText")
	InitWidget("SC_SkillTimeout", "wxSpinCtrl")
	InitWidget("TXT_OwnerClosedistance", "wxStaticText")
	InitWidget("SC_OwnerClosedistance", "wxSpinCtrl")
	InitWidget("TXT_OldHomunType", "wxStaticText")
	InitWidget("CHOICE_OldHomunType", "wxChoice")
	
	InitWidget("CB_FollowAtOnce", "wxCheckBox")
	InitWidget("CB_CircleOnIdle", "wxCheckBox")
	
	InitWidget("BUT_Edit", "wxButton")
	InitWidget("BUT_Add", "wxButton")
	InitWidget("BUT_Remove", "wxButton")
	InitWidget("BUT_Up", "wxButton")
	InitWidget("BUT_Down", "wxButton")
	InitWidget("LC_Tactics", "wxListCtrl")
	
	InitWidget("LB_Mod", "wxListBox")
	InitWidget("LB_Language", "wxListBox")
	
	InitWidget("BUT_SaveConfig", "wxButton") -- only required by 'ApplyTranslation'
	InitWidget("TXT_Version", "wxStaticText")
	
	-- TODO: initialize the remaining reference variables for all the input fields
end


function MainWindow:ApplyTranslation()
	local function SetStaticBoxSizerLabel(hndlObj, label)
		-- hndlObj is a wxWindow object contained in the sizer
		-- whose static box's label we want to set.
		assert(hndlObj)
		assert(type(label) == "string")
		
		local sizer = assert(hndlObj:GetContainingSizer())
		sizer = assert(sizer:DynamicCast("wxStaticBoxSizer"))
		local sb = sizer:GetStaticBox()
		sb:SetLabel(label)
	end
	
	local function ForceSizerRefresh(dlg)
		-- force a sizer refresh by changing the size of the dialog, then changing it back.
		local size = dlg:GetSize()
		local w, h = size:GetWidth(), size:GetHeight()
		dlg:SetSize(w+1, h+1)
		dlg:SetSize(w, h)
	end
	
	-- TAB_General ---------------------------------------------------------------------------------
	self.NB_Notebook:SetPageText(0, _T"General")
	SetStaticBoxSizerLabel(self.HNDL_HomuAttackAndEvade, _T"Homunculus: Attack and Evade")
	self.TXT_AttackWhenHP:SetLabel(_T"Attack when HPs >")
	self.CB_DontMove:SetLabel(_T"don't chase")
	self.TXT_EvadeWhenHP:SetLabel(_T"Evade when HPs <")
	self.CB_Cautious:SetLabel(_T"cautious")
	self.CB_HelpOwnerFirst:SetLabel(_T"Switch target on battle, to go to help the owner")
	self.CB_KillEnemiesFirst:SetLabel(_T"Take care of homunculus enemies first")
	
	SetStaticBoxSizerLabel(self.HNDL_KindHomu, _T"Kind Homunculus")
	self.CB_NoMovingTargets:SetLabel(_T"Don't attack moving monsters")
	self.CB_AdvMotionCheck:SetLabel(_T"Try to detect area spells and frozen monsters")
	
	SetStaticBoxSizerLabel(self.HNDL_Other, _T"Other")
	self.TXT_MaxEnemyDistance:SetLabel(_T"Max enemy distance from the alchemist:")
	self.TXT_SkillTimeout:SetLabel(_T"Max time for skills (ms):")
	self.TXT_OwnerClosedistance:SetLabel(_T"OWNER_CLOSEDISTANCE:")
	self.TXT_OldHomunType:SetLabel(_T"OLD_HOMUN_TYPE:")
	self.CB_FollowAtOnce:SetLabel(_T"Follow the alchemist at once")
	self.CB_CircleOnIdle:SetLabel(_T"Circle around the alchemist when full")
	
	-- TAB_Tactics ---------------------------------------------------------------------------------
	self.NB_Notebook:SetPageText(1, _T"Tactics")
	self.BUT_Edit:SetLabel(_T"Edit")
	self.BUT_Add:SetLabel(_T"Add")
	self.BUT_Remove:SetLabel(_T"Remove")
	self.BUT_Up:SetLabel(_T"Up")
	self.BUT_Down:SetLabel(_T"Down")
	
	-- TAB_Skills ----------------------------------------------------------------------------------
	self.NB_Notebook:SetPageText(2, _T"Skills")
	self.skillWidgets.TXT_SkillsDescription:SetLabel(
		_T("Please choose the minimum amount of SP for each skill and\n" ..
		"the skill level to use (OFF = skill disabled).")
	)
	
	-- TAB_Mod -------------------------------------------------------------------------------------
	self.NB_Notebook:SetPageText(3, _T"Mod")
	
	-- TAB_Language --------------------------------------------------------------------------------
	self.NB_Notebook:SetPageText(4, _T"Language")
	
	-- TODO: ApplyTranslation
	
	--self.____:SetLabel(_T"")
	
	self.BUT_SaveConfig:SetLabel(_T"Save configuration")
	
	-- force a sizer refresh: (NOTE: is there a better way?)
	ForceSizerRefresh(self.dialog)
end


-- saves the configuration to file 'filename'
function MainWindow:SaveConfig(filename)
	assert(type(filename) == "string")
	DebugLog('MainWindow:SaveConfig("' .. filename .. '")')
	
	-- NOTE: add error handler (try/catch block) to all functions that call this one!
	local f = assert(io.open(filename, "w"), string.format(_T'Could not open file "%s"', filename))
	
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
	WriteOpt("OLD_HOMUN_TYPE=" .. ID2OLD_HOMUN_TYPE(self.CHOICE_OldHomunType:GetSelection()))
	
	-- save the auto attack stuff (with a comment that it is disabled and not configurable)
	f:write(
		"\n" ..
		"--------------------------------------------------\n" ..
		"-- Alchemist automatic skills\n" ..
		"-- (These options are not supported by " .. APP_NAME .. ")\n" ..
		"--------------------------------------------------\n" ..
		"-- Alchemist Auto Attacks (AAA)\n" ..
		"AAA_MinHP=100\n" ..
		"AAA_MaxHP=32000\n" ..
		"-- Auto Cart Revolution (ACR)\n" ..
		"ACR = {}\n" ..
		"ACR.MinEnemies=2\n" ..
		"ACR.MinSP=20\n" ..
		"-- Auto Single Target (AST)\n" ..
		"AST = {}\n" ..
		"AST.SkillID=0\n" ..
		"AST.MinSP=20\n" ..
		"AST.Level=5\n" ..
		"-- Auto Aid Potion (AAP)\n" ..
		"CAN_DETECT_NOPOT=true\n" ..
		"AAP = {}\n" ..
		"AAP.Mode=3\n" ..
		"AAP.HP_Perc=65\n" ..
		"AAP.Level=2\n\n"
	)
	
	
	f:write(
		"--------------------------------------------------\n" ..
		"-- Homunculus Skills: minimum SP to activate\n" ..
		"--------------------------------------------------\n"
	)
	-- save skill settings
	SkillsTab.SaveSkills(f, self.skillWidgets)
	
	f:write("\n\n")
	
	f:write(
		"--------------------------------------------------\n" ..
		"-- Tact list: behaviour for each monster\n" ..
		"--------------------------------------------------\n"
	)
	
	WriteOpt("DEFAULT_BEHA = " .. (self.CB_Cautious:GetValue() and "BEHA_react" or "BEHA_attack"))
	
	WriteOpt("DEFAULT_WITH = WITH_slow_power -- not configurable with " .. APP_NAME)
	
	TacticsTab.SaveTactics(f, self.LC_Tactics)
	
	f:close()
	
	-- save selected Mod:
	ModTab.SaveMod(self.LB_Mod, MOD_FILE, MOD_TEMPLATE)
	
	-- save selected language:
	LanguageTab.SaveLang(self.LB_Language, TRANSLATION_PATH, SEL_LANG_FILE)
end


-- loads the configuration from file 'filename'
function MainWindow:LoadConfig(filename)
	assert(type(filename) == "string")
	DebugLog('MainWindow:LoadConfig("' .. filename .. '")')
	
	-- NOTE: add error handler (try/catch block) to all functions that call this one!
	
	local f = io.open(filename, "r")
	if not f then
		--DebugLog("Configuration file could not be opened, creating new file...")
		--self:SaveConfig(filename)
		DebugLog("Configuration file could not be opened, using default settings.")
		return
	end
	
	local options, tactics = LoadConfigOptions(f)
	
	if DEBUG then -- DEBUG:
		print() -- empty line
		DebugLog("options:")
		for k, v in pairs(options) do
			--DebugLog(k, " = ", v)
			DebugLog('"' .. k .. '"', " = ", '"' .. v .. '"')
		end
		print()
		DebugLog("tactics:")
		for i, v in ipairs(tactics) do
			DebugLog(i, " = ", LoadConfigOptions.TactToString(v))
			--DebugLog('"' .. i .. '"', " = ", '"' .. LoadConfigOptions.TactToString(v) .. '"')
		end
		print()
	end
	
	
	-- load regular settings:
	
	-- helper func ReadOpt:
	-- option      - the option (string)
	-- widget      - the widget that will be set by the option (string)
	-- isOneOrZero - if true, the option will be assumed to be boolean, but saved as either 1 or 0.
	-- (isOneOrZero is required for options 'CIRCLE_ON_IDLE' and 'FOLLOW_AT_ONCE')
	local ReadOpt = function(option, widget, isOneOrZero)
		local v = options[option]
		if v then -- if the option exists in Config.lua
			if isOneOrZero then
				if v == "1" then
					v = true
					
				elseif v == "0" then
					v = false
					
				else
					error(string.format(
						_T'Invalid value for option "%s". expected 1 or 0, got: "%s"',
						option, v
					))
				end
				
			elseif option == "DEFAULT_BEHA" then
				if v == "BEHA_react" then
					v = true
					
				else --if v == "BEHA_attack" then
					v = false
				end
				
			elseif option == "OLD_HOMUN_TYPE" then
				v = OLD_HOMUN_TYPE2ID(v)
				
			elseif v == "true" then
				v = true
				
			elseif v == "false" then
				v = false
				
			else
				v = tonumber(v)
			end
			DebugLog(
				'ReadOpt("'..option..'", "'..widget..'", '..tostring(isOneOrZero)..') = '..
				'"'..tostring(v)..'" type('..type(v)..')'
			)
			
			-- OLD_HOMUN_TYPE is a wxChoice, which has a 'SetSelection' method instead of 'SetValue'
			if option == "OLD_HOMUN_TYPE" then
				self[widget]:SetSelection(v)
			else
				self[widget]:SetValue(v)
			end
		end
	end
	
	-- TAB_General:
	ReadOpt("CIRCLE_ON_IDLE", "CB_CircleOnIdle", true)
	ReadOpt("FOLLOW_AT_ONCE", "CB_FollowAtOnce", true)
	ReadOpt("HELP_OWNER_1ST", "CB_HelpOwnerFirst")
	ReadOpt("KILL_YOUR_ENEMIES_1ST", "CB_KillEnemiesFirst")
	ReadOpt("LONG_RANGE_SHOOTER", "CB_DontMove")
	
	--ReadOpt("BOLTS_ON_CHASE_ST", "") not supported by mirai-mod-config
	
	-- read this option into both: SpinCtrl and Slider:
	ReadOpt("HP_PERC_DANGER", "SC_EvadeWhenHP") -- SpinCtrl
	ReadOpt("HP_PERC_DANGER", "SL_EvadeWhenHP") -- Slider
	-- see above:
	ReadOpt("HP_PERC_SAFE2ATK", "SC_AttackWhenHP") -- SpinCtrl
	ReadOpt("HP_PERC_SAFE2ATK", "SL_AttackWhenHP") -- Slider
	
	ReadOpt("OWNER_CLOSEDISTANCE", "SC_OwnerClosedistance")
	ReadOpt("TOO_FAR_TARGET", "SC_MaxEnemyDistance")
	ReadOpt("SKILL_TIME_OUT", "SC_SkillTimeout")
	ReadOpt("NO_MOVING_TARGETS", "CB_NoMovingTargets")
	
	ReadOpt("ADV_MOTION_CHECK", "CB_AdvMotionCheck")
	
	ReadOpt("OLD_HOMUN_TYPE", "CHOICE_OldHomunType")
	
	ReadOpt("DEFAULT_BEHA", "CB_Cautious")
	
	-- load skill settings:
	SkillsTab.LoadSkills(options, self.skillWidgets)
	
	TacticsTab.LoadTactics(tactics, self.LC_Tactics)
	
	ModTab.LoadMod(self.LB_Mod, MOD_FILE)
	
	f:close()
end




--[[
-- TEMP: hide the tab "Language" / TODO: remove this later
function MainWindow:HideLanguageTab(xmlResource)
	local nb = assert(self.dialog:FindWindow(xmlResource.GetXRCID("m_notebook1")))
	nb = assert(nb:DynamicCast("wxNotebook"))
	nb:DeletePage(4)
end
--]]

return MainWindow
