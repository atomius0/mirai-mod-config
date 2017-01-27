-- HomuSkillTable.lua
-- a table listing all homunculus skills for the SkillsTab of mirai-mod-conf

-- format:
-- 'homuSkillTable' is a table containing one table for each Homunculus (homu_table).

-- 'homu_table' looks like this: {homu_name, homu_skills}
-- where: 'homu_name'   is the name of the homunculus as a string
--        'homu_skills' is a table that contains one table for each skill (skill_table).

-- 'skill_table' looks like this: {skill_name, max_lvl, icon_file, option_name}
-- where: 'skill_name'  is the name of the skill
--        'max_lvl'     is the maximum level the skill can have
--        'icon_file'   is the icon that will be shown in the GUI, to the left of the skill name
--        'option_name' is the name of the skill's option table in mirai's "Config.lua".


local homuSkillTable = { -- homus:
	{"Amistr",
		{ -- skills:
			{"Bulwark", 5, "hami_defence.gif", "AS_AMI_BULW"},
			-- add skills here
		}
	},
	{"Testing a new homu",
		{
			{"AAAAAAAAA", 0, "hami_defence.gif", "AS_AMI_BULW"},
			{"BBBBBBBBB", 1, "hami_defence.gif", "AS_AMI_BULW"},
			{"CCCCCCCCC", 5, "hami_defence.gif", "AS_AMI_BULW"},
			{"DDDDDDDDD", 5, "hami_defence.gif", "AS_AMI_BULW"},
			{"EEEEEEEEE", 5, "hami_defence.gif", "AS_AMI_BULW"},
			{"AAAAAAAAA", 5, "hami_defence.gif", "AS_AMI_BULW"},
			{"AAAAAAAAA", 5, "hami_defence.gif", "AS_AMI_BULW"},
			{"AAAAAAAAA", 5, "hami_defence.gif", "AS_AMI_BULW"},
			{"AAAAAAAAA", 5, "hami_defence.gif", "AS_AMI_BULW"},
			{"AAAAAAAAA", 5, "hami_defence.gif", "AS_AMI_BULW"},
			{"AAAAAAAAA", 5, "hami_defence.gif", "AS_AMI_BULW"},
			{"AAAAAAAAA", 5, "hami_defence.gif", "AS_AMI_BULW"},
			{"AAAAAAAAA", 5, "hami_defence.gif", "AS_AMI_BULW"},
			{"AAAAAAAAA", 5, "hami_defence.gif", "AS_AMI_BULW"},
			{"AAAAAAAAA", 5, "hami_defence.gif", "AS_AMI_BULW"},
			{"XXXXXXXXX", 50, "hami_defence.gif", "AS_AMI_BULW"},
		}
	}
	-- add homus here
}

return homuSkillTable
