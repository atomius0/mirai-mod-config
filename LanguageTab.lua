-- mirai-mod-conf
-- LanguageTab functions

local M = {}


-- puts all files from directory 'langPath' ending with '.lua' into the listBox
-- (use const 'TRANSLATION_PATH' for 'langPath')
function M.Init(listBox, langPath)
	assert(listBox)
	DebugLog("LanguageTab.Init")
	-- TODO: Init
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

