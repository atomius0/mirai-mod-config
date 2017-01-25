-- fileEmulator.lua
-- a very simple file handle emulator
-- opens strings as if they were text files
-- (only provides a 'lines' method, because we don't need more than that.)

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


return fileEmu
