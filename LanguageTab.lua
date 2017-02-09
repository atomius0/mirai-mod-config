-- mirai-mod-conf
-- LanguageTab functions

local GetFilesEndingWith = require "GetFilesEndingWith"
local _T = require "TranslationLoader"

local M = {}


-- loads the selected language on the fly, without having to restart the application
function M.OnSelect(listBox, mainWindow)
	assert(listBox)
	assert(mainWindow)
	
	local selection = listBox:GetStringSelection()
	if selection == "" then return end -- if nothing was selected: return without saving
	
	selection = TRANSLATION_PATH .. "/" .. selection .. ".lua"
	
	local baseLang = require(TRANSLATION_PATH:gsub("/", ".") .. ".english")
	local transLang = dofile(selection)
	_T.load(baseLang, transLang)
	mainWindow:ApplyTranslation()
end


-- puts all files from directory 'langPath' ending with '.lua' into the listBox
-- (use const 'TRANSLATION_PATH' for 'langPath')
function M.Init(listBox, langPath)
	assert(listBox)
	assert(type(langPath) == "string")
	DebugLog("LanguageTab.Init")
	
	local files = GetFilesEndingWith(".lua", wx.wxGetCwd() .. "/" .. langPath)
	
	for i, v in ipairs(files) do
		listBox:Append(v:sub(1, -5)) -- cut off the last 4 chars '.lua' (-1 means "until end of string": -1 - 4 = -5)
	end
end


-- save the language selected in listBox to the language file 'langFile' (use const 'SEL_LANG_FILE')
-- langPath is the path to the language files, it is prepended to the selected item from listBox.
function M.SaveLang(listBox, langPath, langFile)
	assert(listBox)
	assert(type(langFile) == "string")
	DebugLog("LanguageTab.SaveLang")
	
	local selection = listBox:GetStringSelection()
	if selection == "" then return end -- if nothing was selected: return without saving
	
	-- add ".lua" back to end of string 'selection' (it got removed by M.Init)
	selection = selection .. ".lua"
	
	-- prepend the config file path to the string 'selection':
	selection = langPath .. "/" .. selection
	
	-- copy contents of the selected language file to 'SEL_LANG_FILE':
	local f = assert(
		io.open(selection, "r"),
		string.format(_T"Error loading file: %s", selection)
	)
	local contents = f:read("*a")
	f:close()
	f = assert(
		io.open(langFile, "w"),
		string.format(_T"Error loading file: %s", langFile)
	)
	f:write(contents)
	f:close()
end


return M

