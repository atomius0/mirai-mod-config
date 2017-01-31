-- mirai-mod-conf
-- SkillsTab functions

local homuSkillTable = require "HomuSkillTable"
local su = require "stringutil"

local M = {}

-- helper function for FillSkillsTab()
-- loads the image 'skillIcon' from SKILL_ICON_PATH, returns a wxBitmap
function M.LoadSkillIcon(skillIcon)
	DebugLog("LoadSkillIcon: " .. skillIcon)
	local imagePath = SKILL_ICON_PATH .. "/" .. skillIcon
	local image = wx.wxImage()
	assert(image:LoadFile(imagePath), "File could not be loaded: '" .. imagePath .. "'")
	local bitmap = assert(wx.wxBitmap(image))
	return bitmap
end


--function M.FillSkillsTab(dialog, xmlResource, skills) -- returns table with references to all widgets
function M.FillSkillsTab(dialog, xmlResource) -- returns table with references to all widgets
	local skills = homuSkillTable
	DebugLog("FillSkillsTab()")
	assert(type(skills) == "table")
	
	-- constants for the "minimum SP for skill use" spinCtrl:
	local SKILL_MINSP, SKILL_MAXSP = 0, 999999
	
	-- skills is a list of tables with the format:
	-- skills[1] = {homuName, SKILL_LIST}
	-- where SKILL_LIST is a list of tables with the format:
	-- SKILL_LIST[1] = {skillName, skillMaxLvl, skillIcon, skillOptionName}
	
	--TODO: add option name param to skill list (how exactly?)
	
	local SCROLLWIN_Skills = assert(dialog:FindWindow(xmlResource.GetXRCID("SCROLLWIN_Skills")))
	SCROLLWIN_Skills = assert(SCROLLWIN_Skills:DynamicCast("wxScrolledWindow"))
	local BSIZER_Skills = assert(SCROLLWIN_Skills:GetSizer())
	
	local TXT_SkillsDescription = wx.wxStaticText(SCROLLWIN_Skills, wx.wxID_ANY,
		"Please choose the minimum amount of SP for each skill and\nthe " ..
		"skill level to use (OFF = skill disabled).", wx.wxDefaultPosition, wx.wxDefaultSize, 0
	)
	TXT_SkillsDescription:Wrap(-1)
	BSIZER_Skills:Add(TXT_SkillsDescription, 0, wx.wxALL, 5)
	
	local widgets = {}
	widgets.TXT_SkillsDescription = TXT_SkillsDescription -- for translation
	
	
	for i, v in ipairs(skills) do
		assert(type(v) == "table")
		assert(#v == 2) -- [1] = homuName, [2] = skillList
		local homuName, skillList = v[1], v[2]
		
		assert(type(homuName ) == "string")
		assert(type(skillList) == "table" )
		
		-- create wxStaticBoxSizer for homunculus:
		local sbSizer = wx.wxStaticBoxSizer(wx.wxVERTICAL, SCROLLWIN_Skills, homuName)
		BSIZER_Skills:Add(sbSizer, 0, wx.wxALL, 5)
		
		for i, v in ipairs(skillList) do
			assert(type(v) == "table")
			assert(#v == 4) -- skillName, skillMaxLvl, skillIcon, skillOptionName
			local skillName, skillMaxLvl, skillIcon, skillOptionName = v[1], v[2], v[3], v[4]
			assert(type(skillName      ) == "string")
			assert(type(skillMaxLvl    ) == "number")
			assert(type(skillIcon      ) == "string")
			assert(type(skillOptionName) == "string")
			
			
			-- create the wxFlexGridSizer containing the skill icon, name, SP- and Level Selectors:
			local fgSizer = wx.wxFlexGridSizer(0, 4, 0, 0)
			fgSizer:AddGrowableCol(1)
			fgSizer:SetFlexibleDirection(wx.wxBOTH)
			fgSizer:SetNonFlexibleGrowMode(wx.wxFLEX_GROWMODE_SPECIFIED)
			sbSizer:Add(fgSizer, 1, wx.wxEXPAND, 5)
			
			
			-- create wxStaticBitmap: (for the skill icon)
			local bitmap = M.LoadSkillIcon(skillIcon)
			local staticBitmap = wx.wxStaticBitmap(
				SCROLLWIN_Skills,
				wx.wxID_ANY,
				bitmap,
				wx.wxDefaultPosition,
				wx.wxSize(bitmap:GetWidth(), bitmap:GetHeight())
			)
			fgSizer:Add(staticBitmap, 0, wx.wxALL, 5)
			
			
			-- create wxStaticText: (for the skill name)
			local staticText = wx.wxStaticText(SCROLLWIN_Skills, wx.wxID_ANY, skillName)
			--staticText:Wrap(-1)
			fgSizer:Add(staticText, 0, wx.wxALL + wx.wxALIGN_CENTER_VERTICAL, 5)
			
			
			-- create wxSpinCtrl: (for selecting the minimum SP to use the skill)
			local spinCtrl = wx.wxSpinCtrl(
				SCROLLWIN_Skills,
				wx.wxID_ANY,
				"",
				wx.wxDefaultPosition,
				wx.wxDefaultSize,
				wx.wxSP_ARROW_KEYS,
				SKILL_MINSP, -- minimal value
				SKILL_MAXSP, -- maximal value
				0            -- initial value
			)
			fgSizer:Add(spinCtrl, 0, wx.wxALL + wx.wxALIGN_CENTER_VERTICAL + wx.wxALIGN_RIGHT, 5)
			
			-- add spinCtrl to widgets table: (as skillOptionName + ".MinSp")
			-- ie: if name is "AS_AMI_BULW" then the table index will be "AS_AMI_BULW.MinSP"
			widgets[skillOptionName .. ".MinSP"] = spinCtrl
			
			
			-- create wxChoice: (for selecting the maximum skill level that should be used)
			
			-- helper function that returns a table in the format:
			-- {"OFF", "Lvl 1", "Lvl 2", ... "Lvl "+maxLvl}
			local genChoiceTable = function(maxLvl)
				local t = {"OFF"}
				for i = 1, maxLvl do
					table.insert(t, "Lvl " .. i)
				end
				return t
			end
			
			local choice = wx.wxChoice(
				SCROLLWIN_Skills,
				wx.wxID_ANY,
				wx.wxDefaultPosition,
				wx.wxDefaultSize,
				genChoiceTable(skillMaxLvl)
			)
			fgSizer:Add(choice, 0, wx.wxALL + wx.wxALIGN_CENTER_VERTICAL + wx.wxALIGN_RIGHT, 5)
			
			widgets[skillOptionName .. ".Level"] = choice
		end
		
		--sbSizer:Layout()
	end
	
	BSIZER_Skills:FitInside(SCROLLWIN_Skills)
	
	--BSIZER_Skills:Layout()
	
	return widgets
end


function M.SaveSkills(f, widgets)
	--DebugLog("SaveSkills()")
	
	-- for each homu in table 'homus':
	-- -- write "-- homu_name" to file 'f'.
	-- -- for each skill's option_name:
	-- -- -- write "option_name = {}" to file 'f'.
	-- -- -- write "option_name.MinSP = " .. widgets[option_name .. ".MinSP"]:GetValue() to file 'f'
	-- -- -- write "option_name.Level = " .. widgets[option_name .. ".Level"]:GetValue() to file 'f'
	
	
	-- for each homu in table 'homus':
	for k, v in ipairs(homuSkillTable) do
		assert(type(v) == "table" and #v == 2)
		
		local homuName = v[1]
		local skills   = v[2]
		
		assert(type(homuName) == "string")
		assert(type(skills) == "table")
		
		f:write("-- " .. homuName .. "\n")
		
		for k, v in ipairs(skills) do
			assert(type(v) == "table" and #v == 4)
			
			local skillName  = v[1]
			local optionName = v[4]
			
			assert(type(skillName) == "string")
			assert(type(optionName) == "string")
			
			-- write list initialization:
			f:write(optionName .. " = {} -- " .. skillName .. "\n")
			
			-- write .MinSP value:
			f:write(optionName .. ".MinSP = " .. widgets[optionName .. ".MinSP"]:GetValue() .. "\n")
			
			
			-- get the selected level from the wxChoice:
			local selection = widgets[optionName .. ".Level"]:GetSelection()
			-- if selection is -1, nothing has been chosen in the wxChoice
			-- that means, the wxChoice was not initialized!
			assert(selection >= 0,
				'invalid choice "' .. selection .. '" in wxChoice "' .. optionName .. '"'
			)
			
			-- write .Level value:
			f:write(optionName .. ".Level = " .. selection .. "\n")
			
			f:write("\n")
		end
	end
end


function M.LoadSkills(options, widgets)
	DebugLog("LoadSkills()")
	assert(type(options) == "table")
	assert(type(widgets) == "table")
	
	for k, v in pairs(widgets) do
		assert(type(k) == "string")
		
		local opt = tonumber(options[k]) -- tonumber(nil) returns nil, so this is fine.
		
		if su.endsWith(k, ".MinSP") then
			if opt then
				v:SetValue(opt)
			else
				v:SetValue(0)
			end
			
		elseif su.endsWith(k, ".Level") then
			if opt then
				v:SetSelection(opt)
			else
				v:SetSelection(0) -- if we don't set this to 0, the wxChoice will stay empty!
			end
			
		elseif k ~= "TXT_SkillsDescription" then -- ignore TXT_SkillsDescription
			-- everything else is an error:
			error("unexpected key in table 'widgets': " .. k)
		end
	end
end


return M
