-- mirai-mod-conf
-- for now, this is just a simple program that loads and displays the mirai-mod-conf MainWindow

package.cpath = package.cpath..";./?.dll;./?.so;../lib/?.so;../lib/vc_dll/?.dll;../lib/bcc_dll/?.dll;../lib/mingw_dll/?.dll;"
require("wx")

class = require "30log"

DEBUG = true

if DEBUG then
	print("### debug mode enabled ###")
	require "strict"
	function DebugLog(...) print("DEBUG: ", ...) end
else
	function DebugLog(...) --[[ do nothing ]] end
end

-- constants:
XRC_FILE = "config.xrc"
APP_NAME = "MirAI Mod Config"


-- globals:
-- MARK: don't make this global for now, it's probably not needed.
--xmlResource = nil



function ErrorHandler(err)
	wx.wxMessageBox(err, APP_NAME, wx.wxOK + wx.wxICON_EXCLAMATION)
end

-- TODO: test this
function LoadXmlResource(xrcFile)
	local xmlResource = wx.wxXmlResource()
	xmlResource:InitAllHandlers()
	
	--local logNo = wx.wxLogNull() -- temporarily disable wx error messages
	
	assert(xmlResource:Load(xrcFile), "Error loading File: " .. xrcFile)
	
	--logNo:delete() -- re-enable error messages
	
	return xmlResource
end

-- class MainWindow:
MainWindow = class("MainWindow")

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
	end
	
	
	function handlers.OnAttackWhenHP(event)
		DebugLog("MainWindow: OnAttackWhenHP")
		event:Skip()
		
		local src = event:GetId()
		if src == MainWindow.IDs.SL_AttackWhenHP then
			DebugLog("source: SL_AttackWhenHP")
			self.SC_AttackWhenHP:SetValue(event:GetInt())
			
		elseif src == MainWindow.IDs.SC_AttackWhenHP then
			DebugLog("source: SC_AttackWhenHP")
			self.SL_AttackWhenHP:SetValue(event:GetInt())
		end
	end
	
	function handlers.OnEvadeWhenHP(event)
		DebugLog("MainWindow: OnEvadeWhenHP")
		event:Skip()
		
		local src = event:GetId()
		if src == MainWindow.IDs.SL_EvadeWhenHP then
			DebugLog("source: SL_EvadeWhenHP")
			self.SC_EvadeWhenHP:SetValue(event:GetInt())
			
		elseif src == MainWindow.IDs.SC_EvadeWhenHP then
			DebugLog("source: SC_EvadeWhenHP")
			self.SL_EvadeWhenHP:SetValue(event:GetInt())
		end
	end
	
	-- TODO: combine these handler functions, by comparing event:GetEventType() with the wx.wxEVT_* constants
	--       and using event:GetId() to get the ID of the event source. (look it up in MainWindow.IDs)
	
	
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
	
	
	-- initialize the reference variables for the input fields
	self.SL_AttackWhenHP = assert(self.dialog:FindWindow(MainWindow.IDs.SL_AttackWhenHP))
	self.SL_AttackWhenHP = assert(self.SL_AttackWhenHP:DynamicCast("wxSlider"))
	
	self.SC_AttackWhenHP = assert(self.dialog:FindWindow(MainWindow.IDs.SC_AttackWhenHP))
	self.SC_AttackWhenHP = assert(self.SC_AttackWhenHP:DynamicCast("wxSpinCtrl"))
	
	self.SL_EvadeWhenHP = assert(self.dialog:FindWindow(MainWindow.IDs.SL_EvadeWhenHP))
	self.SL_EvadeWhenHP = assert(self.SL_EvadeWhenHP:DynamicCast("wxSlider"))
	
	self.SC_EvadeWhenHP = assert(self.dialog:FindWindow(MainWindow.IDs.SC_EvadeWhenHP))
	self.SC_EvadeWhenHP = assert(self.SC_EvadeWhenHP:DynamicCast("wxSpinCtrl"))
	
	-- TODO: initialize the remaining reference variables for all the input fields
	
	
	-- connect events to handler functions
	
	-- for continuous dragging with the mouse:
	--self.dialog:Connect(MainWindow.IDs.SL_AttackWhenHP, wx.wxEVT_SCROLL_THUMBTRACK, handlers.OnSL_AttackWhenHP)
	-- for movement via keyboard:
	--self.dialog:Connect(MainWindow.IDs.SL_AttackWhenHP, wx.wxEVT_SCROLL_CHANGED, handlers.OnSL_AttackWhenHP)
	
	-- for all movement events:
	-- (see wxWidgets docs: class "wxCommandEvent")
	self.dialog:Connect(MainWindow.IDs.SL_AttackWhenHP, wx.wxEVT_COMMAND_SLIDER_UPDATED, handlers.OnAttackWhenHP)
	
	-- found the wxEVT_* constant via wxLua sample program "controls.wx.lua"
	self.dialog:Connect(MainWindow.IDs.SC_AttackWhenHP, wx.wxEVT_COMMAND_SPINCTRL_UPDATED, handlers.OnAttackWhenHP)
	
	self.dialog:Connect(MainWindow.IDs.SL_EvadeWhenHP, wx.wxEVT_COMMAND_SLIDER_UPDATED, handlers.OnEvadeWhenHP)
	self.dialog:Connect(MainWindow.IDs.SC_EvadeWhenHP, wx.wxEVT_COMMAND_SPINCTRL_UPDATED, handlers.OnEvadeWhenHP)
	
	-- TODO: connect remaining events to handler functions
	
	-- connect the closeevent to the OnClose function:
	self.dialog:Connect(wx.wxEVT_CLOSE_WINDOW, handlers.OnClose)
	-- TODO: next!
	
	--TODO: load Config.lua? (and if it doesn't exist, create it)
	
	self.dialog:Center()
	self.dialog:Show(true)
end


-- no, function LoadXMLResource will not be a member of class MainWindow, since the xml resource
-- will possibly be shared among multiple windows/dialogs.
--function MainWindow.LoadXmlResource()


--local xmlResource = LoadXmlResource(XRC_FILE)

xpcall(function() --try
	local xmlResource = LoadXmlResource(XRC_FILE)
	local mainWin = MainWindow(xmlResource)
	
	DebugLog(type(xmlResource)) -- debug
end, ErrorHandler)



wx.wxGetApp():MainLoop()

