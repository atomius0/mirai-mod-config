-- fileEmulator.lua
-- a very simple file handle emulator
-- opens strings as if they were text files
-- (only provides a 'lines' method, because we don't need more than that.)


--[[
-- usage:
local fileEmu = require "fileEmu"
local f = fileEmu("Sample file\nwith multiple\nlines\n\nend")

for line in f:lines() do
	print(line)
end

f:close()
--]]


local class = require "30log"
local su = require "stringutil"

local fileEmu = class("fileEmulator")

function fileEmu:init(s)
	assert(type(s) == "string")
	
	self.s = s
end

-- very simple implementation, but we don't need more than this
function fileEmu:lines()
	return su.gsplit(self.s, "\n", true)
end

-- dummy function
function fileEmu:close()
	-- do nothing
end

return fileEmu
