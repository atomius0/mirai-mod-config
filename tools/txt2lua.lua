-------------
-- txt2lua --
-------------

-- a small tool that converts a text file to a lua source file
-- that returns a string with the contents of the text file.

-- functions string.starts and string.ends are modified from:
-- http://lua-users.org/wiki/StringRecipes

-- returns true if string 'str' starts with 's'
function string.starts(str, s)
	return string.sub(str, 1, string.len(s)) == s
end

-- returns true if string 'str' ends with 's'
function string.ends(str, s)
	return s == "" or string.sub(str, -string.len(s)) == s
end


function textToLua(s)
	local eq_s = ""
	if string.ends(s, "]") then eq_s = "=" end
	
	while string.find(s, "[" .. eq_s .. "[", 1, true) or 
	      string.find(s, "]" .. eq_s .. "]", 1, true) do
		eq_s = eq_s .. "="
	end
	
	return "return ".."["..eq_s.."["..s.."]"..eq_s.."]"
end


function usage()
	print("txt2lua")
	print('converts a text file to a lua source file containing "return [[file contents]]"')
	print("Usage: txt2lua.lua input output")
end


function main()
	if (not arg) or #arg ~= 2 then
		usage()
		return
	end
	
	local input, output = arg[1], arg[2]
	
	local input_handle = io.open(input, "r")
	assert(input_handle, "could not open file '" .. input .. "'")
	local input_data = input_handle:read("*a")
	
	local output_data = textToLua(input_data)
	
	local output_handle = io.open(output, "w")
	assert(output_handle, "could not open file '" .. output .. "'")
	output_handle:write(output_data)
	output_handle:close()
end

main()
