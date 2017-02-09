-- mirai-mod-conf
-- LanguageTab functions

local GetFilesEndingWith = require "GetFilesEndingWith"
local M = {}


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

--[[ no, we will put this in another file which will be 'require'd by main.lua
-- loads the language from file 'langFile' (use const 'SEL_LANG_FILE')
function M.LoadLang(langFile) -- needs no parameters
	assert(type(langFile) == "string")
	DebugLog("LanguageTab.LoadLang")
	
	-- TODO: LoadLang
end
--]]

-- save the language selected in listBox to the language file 'langFile' (use const 'SEL_LANG_FILE')
function M.SaveLang(listBox, langFile)
	assert(listBox)
	assert(type(langFile) == "string")
	DebugLog("LanguageTab.SaveLang")
	
	-- TODO: SaveLang
end


return M

