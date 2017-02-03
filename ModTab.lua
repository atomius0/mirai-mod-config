-- mirai-mod-conf
-- ModTab functions

--local su = require "stringutil" -- do we need this?

local M = {}


-- helper function: returns a table containing strings of all filenames in directory dir
-- whose names end with string 'with'
local function GetFilesEndingWith(dir, with)

end


-- puts all files ending with "_Mod.lua" into the listBox
function M.Init(listBox)
	assert(listBox)
	DebugLog("ModTab.Init")
	
	local dirString = wx.wxGetCwd()
	local dir = wx.wxDir(dirString)
	assert(dir, string.format("Error opening working directory: %s", dirString))
	
	
	
	local ok, name = dir:GetFirst("", wx.wxDIR_FILES + wx.wxDIR_HIDDEN)
	while ok do
		print(ok, name)
		ok, name = dir:GetNext(name)
	end
	
	-- TODO: Init
end


-- reads the selected mod from file with name fileName, and selects it in the listBox
function M.LoadMod(listBox, fileName)
	assert(listBox)
	assert(fileName)
	-- TODO: LoadMod
	-- TODO: how to read the selected mod?
end


-- writes the name of the file selected in listBox into file named fileName
-- uses file named selectedModTemplate as template
function M.SaveMod(listBox, fileName, selectedModTemplate)
	assert(listBox)
	assert(fileName)
	assert(selectedModTemplate)
	-- TODO: SaveMod
end


return M
