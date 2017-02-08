-- TranslationLoader.lua
-- simple translation loader
-- written by atomius, 2017

local M = {}

M.trans = {}

-- loads the translation.
-- baseLang  is a table containing the strings to be translated
-- transLang is a table containing the translated strings, ie:
-- -- baseLang  = {"Hello, World!", "Goodbye"}
-- -- transLang = {"Hallo, Welt!",  "Auf Wiedersehen"}
function M.load(baseLang, transLang)
	assert(type(baseLang ) == "table")
	assert(type(transLang) == "table")
	
	for i = 1, #baseLang do
		M.trans[baseLang[i]] = transLang[i]
	end
end


-- the translation function:
function M._T(s)
	--[[ old debug code:
	if M.trans[s] then
		DebugLog(string.format("_T: '%s' = '%s'", s, M.trans[s]))
	else
		DebugLog(string.format("_T, no translation: '%s'", s))
		for k,v in pairs(M.trans) do print(k,v) end
		io.read()
	end
	--]]
	return M.trans[s] or s
end


local mt = {
	__call = function(t, ...)
		return t._T(...)
	end
}

return setmetatable(M, mt)

--[[ usage:
local _T = require "TranslationLoader"

local base  = {"Hello, World!", "Goodbye"}
local trans = {"Hallo, Welt!",  "Auf Wiedersehen"}

_T.load(base, trans)

print(_T("Hello, World!"))
print(_T("Goodbye"))
--]]

