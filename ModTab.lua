-- mirai-mod-conf
-- ModTab functions

local su = require "stringutil"
local _T = require "TranslationLoader"

local M = {}


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
	
	-- construct a new environment table with a getModule function
	-- the getModule function is stored with the keys "dofile" and "require"
	-- load and execute fileName as a coroutine
	-- the getModule function will yield once it is called, and return the name of the selected mod.
	
	local function GetModule(path)
		if su.endsWith(path, ".lua") then -- old way, relative path separated by forward slashes:
			if path:find("/", 1, true) then -- if path contains "/":
				local sp = su.split(path, "/", true) -- split path by "/"
				path = sp[#sp] -- path = last element of split path (the filename)
			end
			
		else -- new way, module identifier separated by "."
			if path:find(".", 1, true) then -- if path contains ".":
				local sp = su.split(path, ".", true)
				path = sp[#sp]
			end
			-- add ".lua" extension to filename,
			-- since the module path does not contain the extension:
			path = path .. ".lua"
		end
		
		coroutine.yield(path)
	end
	
	-- construct an environment table for the SelectedMod.lua
	local env = {
		["_G"] = nil, -- defined below
		["dofile"]  = GetModule,
		["require"] = GetModule,
	}
	env._G = env
	
	-- load the SelectedMod.lua into function f:
	local f, err = loadfile(fileName)
	if not f then
		if DEBUG then
			-- only raise an error if the file could be found, but there was some other error:
			if not err:find("No such file or directory", 1, true) then error(err) end
		end
		return -- file could not be opened or an error occured while reading: return
	end
	
	-- set table 'env' as environment of function f:
	setfenv(f, env)
	-- now, set f to be a wrapper function for running the function we just loaded as a coroutine:
	f = coroutine.wrap(f)
	
	-- call it, catching all errors:
	local ok, s = pcall(f)
	
	if DEBUG then -- in debug mode, errors will be escalated, not silently ignored:
		assert(ok, s)
	end
	
	if not ok then
		return -- if an error occured, do not select the module, just return silently.
	end
	
	DebugLog(string.format('SelectedMod: "%s"', s))
	
	
	-- finally, select the mod in the listBox:
	--ok = listBox:SetStringSelection(s) -- this selects, but it doesn't return anything...
	local function listBoxSetStringSelection(listBox, s) -- diy fix...
		for i = 1, listBox:GetCount() do
			local c = listBox:GetString(i-1)
			if c == s then
				listBox:SetSelection(i-1)
				return true
			end
		end
		return false
	end
	
	ok = listBoxSetStringSelection(listBox, s)
	
	if DEBUG then
		assert(ok, "SelectedMod could not be found in listCtrl!")
	end
	-- if debug mode is disabled,
	-- then we won't do anything if the SelectedMod does not exist in the listCtrl.
	
	-- old plan:
	--[[
	
	-- select listBox entry with name returned by: GetSelectedMod(fileName)
	
	-- put the stuff below into a helper function: GetSelectedMod
	
	-- read file line by line, if line starts with "--" then:
	-- -- skip it.
	-- else:
	-- -- local path = GetStringLiteral(line)
	-- -- if not path then: continue
	-- -- local modName = ModNameFromPath(path)
	-- -- if not modName then: continue
	
	-- local function GetStringLiteral(line): extracts a string literal from string 'line':
	-- -- read from first '"' until next '"', store everything in between in variable 's', return 's'
	
	-- local function ModNameFromPath(path): returns the module name from path 'path'
	-- -- if path ends with ".lua" then: -- old way, relative path:
	-- -- -- if path contains "/": split path by "/", path = last element of split-table
	-- -- -- return path
	-- -- else: new way
	-- -- -- if path contains ".": split path by ".", path = last element of split-table
	-- -- -- return path
	--]]
end


-- writes the name of the file selected in listBox into file named fileName
-- uses file named selectedModTemplate as template
function M.SaveMod(listBox, fileName, selectedModTemplate)
	assert(listBox)
	assert(type(fileName) == "string")
	assert(type(selectedModTemplate) == "string")
	DebugLog("ModTab.SaveMod")
	
	-- get selected string from listBox:
	local selection = listBox:GetStringSelection()
	if selection == "" then return end -- if nothing was selected: return without saving
	
	-- strip ".lua" from end of string 'selection':
	-- cut off the last 4 characters, ".lua" (-1 means "until end of string": -1 - 4 = -5)
	selection = selection:sub(1, -5)
	
	-- read contents of file 'selectedModTemplate' into a string 'modTemplate'
	local f = assert(
		io.open(selectedModTemplate, "r"),
		string.format(_T'Could not open file "%s"', selectedModTemplate)
	)
	local modTemplate = f:read("*a") -- read whole file into string modTemplate
	f:close()
	assert(#modTemplate > 0) -- string should not be empty
	
	-- replace the substring '%MOD%' from template with the selected Mod:
	local out, num = modTemplate:gsub("%%MOD%%", selection)
	-- make sure that at least one instance of '%MOD%' was replaced:
	assert(num >= 1,
		string.format(_T'Could not find substring "%%MOD%%" in file "%s"', selectedModTemplate)
	)
	
	-- write string 'out' to file 'fileName'
	f = assert(io.open(fileName, "w"), string.format(_T'Could not open file "%s"', fileName))
	f:write(out)
	f:close()
end


return M
