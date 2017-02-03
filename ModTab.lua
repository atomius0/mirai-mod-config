-- mirai-mod-conf
-- ModTab functions

local su = require "stringutil"

local M = {}


-- puts all files ending with "_Mod.lua" into the listBox
function M.Init(listBox)
	assert(listBox)
	
	--local dirHandle = wx.wxDir
	
	-- TODO: Init
end


-- reads the selected mod from file with name fileName, and selects it in the listBox
function M.LoadMod(listBox, fileName)
	assert(listBox)
	assert(fileName)
	-- TODO: LoadMod
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
