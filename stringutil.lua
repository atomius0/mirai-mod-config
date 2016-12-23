local M = {}

-- functions M.startsWith and M.endsWith are modified from:
-- http://lua-users.org/wiki/StringRecipes

-- returns true if string 'str' starts with 'subStr'
function M.startsWith(str, subStr)
	return string.sub(str, 1, string.len(subStr)) == subStr
end

-- returns true if string 'str' ends with 'subStr'
function M.endsWith(str, subStr)
	return subStr == "" or string.sub(str, -string.len(subStr)) == subStr
end


--[=[
-- from http://lua-users.org/wiki/SplitJoin
--[[
function string:split(sep)
        local sep, fields = sep or ":", {}
        local pattern = string.format("([^%s]+)", sep)
        self:gsub(pattern, function(c) fields[#fields+1] = c end)
        return fields
end
--]]


function M.split(str, sep)
        --local sep, fields = sep or ":", {}
		local fields = {}
		assert(sep)
        local pattern = string.format("([^%s]+)", sep)
        str:gsub(pattern, function(c) fields[#fields+1] = c end)
        return fields
end
--]=]


-- from http://lua-users.org/wiki/SplitJoin
-- by CosminApreutesei
--[[ original:
function string.gsplit(s, sep, plain)
	local start = 1
	local done = false
	local function pass(i, j, ...)
		if i then
			local seg = s:sub(start, i - 1)
			start = j + 1
			return seg, ...
		else
			done = true
			return s:sub(start)
		end
	end
	return function()
		if done then return end
		if sep == '' then done = true return s end
		return pass(s:find(sep, start, plain))
	end
end
--]]

-- iterator:
function M.gsplit(s, sep, plain)
	local start = 1
	local done = false
	local function pass(i, j, ...)
		if i then
			local seg = s:sub(start, i - 1)
			start = j + 1
			return seg, ...
		else
			done = true
			return s:sub(start)
		end
	end
	return function()
		if done then return end
		if sep == '' then done = true return s end
		return pass(s:find(sep, start, plain))
	end
end


function M.split(s, sep, plain)
	local t = {}
	for c in M.gsplit(s, sep, plain) do table.insert(t, c) end
	return t
end

-- if the global variable STRINGUTIL_ADD_STRING_METHODS has been set to true
-- before loading the module, all stringutil functions will be added as methods to the string table.
if STRINGUTIL_ADD_STRING_METHODS then
	for k, v in pairs(M) do
		string[k] = v
	end
end

return M
