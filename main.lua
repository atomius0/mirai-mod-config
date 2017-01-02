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
	-- TODO: self.* reference variables for all input fields (eg. wxSlider, wxSpinCtrl, wxListBox)
	
	local handlers = {} -- table for all event handler functions
	
	function handlers.OnClose(event)
		DebugLog("MainWindow: OnClose")
		event:Skip()
		-- TODO: check if there are unsaved changes and warn user before quitting.
		self.dialog:Show(false)
		self.dialog:Destroy()
	end
	-- TODO: event handler functions, eg: "function handlers.OnSomething(event)"
	
	
	-- TODO: get IDs / init wxWindow ID values (yes, before loading the dialog)
	
	-- load the dialog:
	self.dialog = wx.wxDialog()
	assert(xmlResource:LoadDialog(self.dialog, wx.NULL, "MainWindow"), 
		"Error loading dialog 'MainWindow'"
	)
	
	-- TODO: initialize the reference variables for all the input fields
	
	
	-- TODO: connect events to handler functions
	
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

