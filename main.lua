-- mirai-mod-conf
-- for now, this is just a simple program that loads and displays the mirai-mod-conf MainWindow

package.cpath = package.cpath..";./?.dll;./?.so;../lib/?.so;../lib/vc_dll/?.dll;../lib/bcc_dll/?.dll;../lib/mingw_dll/?.dll;"
require("wx")

DEBUG      = true
USE_STRICT = true

if DEBUG then
	print("### debug mode enabled ###")
	if USE_STRICT then require "strict" end
	function DebugLog(...) print("DEBUG: ", ...) end
else
	function DebugLog(...) --[[ do nothing ]] end
end

class = require "30log"
MainWindow = require "MainWindow"
_T = require "TranslationLoader"

-- constants:
APP_VERSION      = "v0.1.0"
XRC_FILE         = "config/config.xrc"
APP_NAME         = "MirAI Mod Config"
CONFIG_FILE      = "Config.lua"
MOD_FILE         = "SelectedMod.lua"
MOD_TEMPLATE     = "config/SelectedModTemplate.lua"
SKILL_ICON_PATH  = "config"
TRANSLATION_PATH = "config/lang"
SEL_LANG_FILE    = "config/lang/lang"

-- globals:
-- MARK: don't make this global for now, it's probably not needed.
--xmlResource = nil



function ErrorHandler(err)
	DebugLog("ErrorHandler: " .. err)
	wx.wxMessageBox(err, APP_NAME, wx.wxOK + wx.wxICON_EXCLAMATION)
	os.exit()
end


function LoadXmlResource(xrcFile)
	local xmlResource = wx.wxXmlResource()
	xmlResource:InitAllHandlers()
	
	--local logNo = wx.wxLogNull() -- temporarily disable wx error messages
	
	assert(xmlResource:Load(xrcFile), "Error loading File: " .. xrcFile)
	
	--logNo:delete() -- re-enable error messages
	
	return xmlResource
end


local function LoadTranslation()
	
	local function LoadSelLang()
		-- we don't use dofile here,
		-- because we want nothing to happen if the file cannot be read.
		-- (dofile throws an error if the file does not exist)
		local f = io.open(SEL_LANG_FILE)
		if not f then return nil end
		local s = f:read("*a")
		return assert(loadstring(s))()
	end
	
	-- baseLang is a table containing the strings to be translated:
	local baseLang  = require(TRANSLATION_PATH:gsub("/", ".") .. ".english")
	local transLang = LoadSelLang()
	if not transLang then return end -- if there was no language selected, don't load it.
	_T.load(baseLang, transLang)
end


xpcall(function() --try
	LoadTranslation()
	local xmlResource = LoadXmlResource(XRC_FILE)
	local mainWin = MainWindow(xmlResource)
end, ErrorHandler)


wx.wxGetApp():MainLoop()
