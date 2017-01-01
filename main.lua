-- mirai-mod-conf
-- for now, this is just a simple program that loads and displays the mirai-mod-conf MainWindow

package.cpath = package.cpath..";./?.dll;./?.so;../lib/?.so;../lib/vc_dll/?.dll;../lib/bcc_dll/?.dll;../lib/mingw_dll/?.dll;"
require("wx")

class = require "30log"

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
	
	local logNo = wx.wxLogNull() -- temporarily disable wx error messages
	
	assert(xmlResource:Load(xrcFile), "Error loading File: " .. xrcFile)
	
	logNo:delete() -- re-enable error messages
	
	return xmlResource
end

-- class MainWindow:
MainWindow = class("MainWindow")

MainWindow.IDs = {}


function MainWindow:init(xmlResource)
	-- no parent parameter for this function,
	-- since we will only ever have one instance of MainWindow
	
	-- TODO: keep a reference to xmlResource?
	--       we might need it when MainWindow wants to create a child window.
	
	self.dialog = nil
	-- TODO: self.* reference variables for all input fields (eg. wxSlider, wxSpinCtrl, wxListBox)
	
	local handlers = {} -- table for all event handler functions
	
	-- TODO: event handler functions, eg: "function handlers.OnSomething(event)"
	
	--TODO: next!
end


-- no, function LoadXMLResource will not be a member of class MainWindow, since the xml resource
-- will possibly be shared among multiple windows/dialogs.
--function MainWindow.LoadXmlResource()


--local xmlResource = LoadXmlResource(XRC_FILE)

xpcall(function() --try
	local xmlResource = LoadXmlResource(XRC_FILE)
	local mainWin = MainWindow()
end, ErrorHandler)


print(xmlResource) -- debug

wx.wxGetApp():MainLoop()

