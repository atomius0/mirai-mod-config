-- mirai-mod-conf
-- for now, this is just a simple program that loads and displays the mirai-mod-conf MainWindow

package.cpath = package.cpath..";./?.dll;./?.so;../lib/?.so;../lib/vc_dll/?.dll;../lib/bcc_dll/?.dll;../lib/mingw_dll/?.dll;"
require("wx")

class = require "30log"

-- constants:
XRC_FILE = "config.xrc"
APP_NAME = "MirAI Mod Config"


-- globals:
xmlResource = nil



-- TODO: test this
function LoadXmlResource(xrcFile)
	xmlResource = wx.wxXmlResource()
	xmlResource:InitAllHandlers()
	
	local logNo = wx.wxLogNull() -- temporarily disable wx error messages
	
	assert(xmlResource:Load(xrcFile), "Error loading File: " .. xrcFile)
	
	logNo:delete() -- re-enable error messages
end

-- class MainWindow:
MainWindow = class("MainWindow")

MainWindow.IDs = {}


-- no, function LoadXMLResource will not be a member of class MainWindow, since the xml resource
-- will possibly be shared among multiple windows/dialogs.
--function MainWindow.LoadXmlResource()


