-- mirai-mod-conf
-- ModTab functions

local su = require "stringutil"

local M = {}


-- helper function: returns a table containing strings of all filenames
-- whose names end with string 'with' from directory 'dir'
local function GetFilesEndingWith(with, dir)
	local dh = wx.wxDir(dir)
	assert(dh, string.format("Error opening directory: %s", dir))
	
	local files = {}
	
	local ok, name = dh:GetFirst("", wx.wxDIR_FILES + wx.wxDIR_HIDDEN)
	while ok do
		if su.endsWith(name, with) then
			table.insert(files, name)
		end
		ok, name = dh:GetNext(name)
	end
	
	return files
end


-- puts all files ending with "_Mod.lua" into the listBox
function M.Init(listBox)
	assert(listBox)
	DebugLog("ModTab.Init")
	
	local files = GetFilesEndingWith("_Mod.lua", wx.wxGetCwd())
	
	for k, v in pairs(files) do
		listBox:Append(v)
	end
end


-- reads the selected mod from file with name fileName, and selects it in the listBox
function M.LoadMod(listBox, fileName)
	assert(listBox)
	assert(fileName)
	DebugLog("ModTab.LoadMod")
	-- TODO: LoadMod
	-- TODO: how to read the selected mod?
end


-- writes the name of the file selected in listBox into file named fileName
-- uses file named selectedModTemplate as template
function M.SaveMod(listBox, fileName, selectedModTemplate)
	assert(listBox)
	assert(fileName)
	assert(selectedModTemplate)
	DebugLog("ModTab.SaveMod")
	-- TODO: SaveMod
end


return M
