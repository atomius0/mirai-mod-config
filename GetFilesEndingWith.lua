-- mirai-mod-conf
-- helper function GetFilesEndingWith

local su = require "stringutil"
local _T = require "TranslationLoader"

-- helper function: returns a table containing strings of all filenames
-- whose names end with string 'with' from directory 'dir'
local function GetFilesEndingWith(with, dir)
	local dh = wx.wxDir(dir)
	assert(dh, string.format(_T"Error opening directory: %s", dir))
	
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

return GetFilesEndingWith
