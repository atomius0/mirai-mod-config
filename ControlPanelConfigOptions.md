# Mapping of original MirAI CP options to Config.lua variables:

## Auto Aid Potion (Potion Pitcher) Support:

	### First dropdown menu:
	- Disabled:                              AAP.Mode=0
	- Support evasive maneuvers:             AAP.Mode=1
	- Support attacks:                       AAP.Mode=2
	- Support attacks and evasive maneuvers: AAP.Mode=3
	- Support everytime (in idle mode too):  AAP.Mode=4

	### Second dropdown menu:
	- Throw Red Potions (lvl 1):    AAP.Level=1
	- Throw Orange Potions (lvl 2): AAP.Level=2
	- Throw Yellow Potions (lvl 3): AAP.Level=3
	- Throw White Potions (lvl 4):  AAP.Level=4

	### Slider "When homunculus HPs are less than:"
	- AAP.HP_Perc=X  (X is the slider's percentage) (0-100)



## Homunculus Attack and Evade:

	- Attack when HPs >: HP_PERC_SAFE2ATK=X  (X is the slider's percentage) (0-100)
	- Evade when HP <:   HP_PERC_DANGER=X    (X is the slider's percentage) (0-100)

	The two sliders above are linked. the following is always true:
	- Attack >= Evade
	- Evade  <= Attack

	eg: When the user tries to lower the Attack slider below the Evade slider, Evade will follow automatically.

	And when the user tries to raise the Evade slider above the Attack slider, Attack will follow, too.


	### Checkbox: "CB_DontChase"
	- [x]:  LONG_RANGE_SHOOTER=true
	- [ ]:  LONG_RANGE_SHOOTER=false

	### Checkbox: "Cautious"
	- [x]:  DEFAULT_BEHA = BEHA_react
	- [ ]:  DEFAULT_BEHA = BEHA_attack

	### Checkbox: "Switch target"
	- [x]:  HELP_OWNER_1ST=true
	- [ ]:  HELP_OWNER_1ST=false

	### Checkbox: "Finish yours first"
	- [x]:  KILL_YOUR_ENEMIES_1ST=true
	- [ ]:  KILL_YOUR_ENEMIES_1ST=false



## GB_Motion:

	### Checkbox: "No moving targets"
	- [x]:  NO_MOVING_TARGETS=true
	- [ ]:  NO_MOVING_TARGETS=false

	### Checkbox: "CB_AdvMotion"
	- [x]:  ADV_MOTION_CHECK=true
	- [ ]:  ADV_MOTION_CHECK=false



## Alchemist Auto Attacks:

	### Checkbox: "On Chase"
	- [x]:  BOLTS_ON_CHASE_ST=true
	- [ ]:  BOLTS_ON_CHASE_ST=false

	### HP Range:
	- first spin control:   AAA_MinHP=X  (X is the value chosen in the spin control) (default=100)
	- second spin control:  AAA_MaxHP=X  (X is the value chosen in the spin control) (default=32000)

	### Cart Revolution:
	#### Dropdown menu:
	- disabled:               ACR.MinEnemies=0
	- for single target too:  ACR.MinEnemies=1
	- for 2 or more targets:  ACR.MinEnemies=2
	- for 3 or more targets:  ACR.MinEnemies=3
	- for 4 or more targets:  ACR.MinEnemies=4

	#### Spin control "Min SP":
	- ACR.MinSP=X  (X is the value chosen in the spin control) (default=20)


	### Weapon:
	#### First dropdown menu:
	- -:                        AST.SkillID=0
	- Bash (Cutlus):            AST.SkillID=5
	- Cold Bolt (Ice Falchion): AST.SkillID=14
	- Fire Bold (Fireblend):    AST.SkillID=19
	- Tomahawk:                 AST.SkillID=337

	#### Second dropdown menu:
	- OFF:    AST.Level=0
	- Lvl 1:  AST.Level=1
	- Lvl 2:  AST.Level=2
	- Lvl 3:  AST.Level=3
	- Lvl 4:  AST.Level=4
	- Lvl 5:  AST.Level=5

	#### Spin control:
	AST.MinSP=X  (X is the value chosen in the spin control) (default=20)



## Tact List:
	The tact list is saved as a table called 'Tact' (Tact = {})
	each entry in the list is either a line in the form of:
	
	Tact[ID] = {"NAME", BEHA_*, WITH_*, LVL, AAA}
	
	where:
		'ID'     is the id of the monster as a number (default=0)
		'NAME'   is the name of the monster (only for display, the AI ignores this)
		'BEHA_*' is the behaviour as a constant. one of: (default=BEHA_react)
		            BEHA_coward,
					BEHA_react_1st,
					BEHA_react,
					BEHA_react_last,
					BEHA_attack_1st,
					BEHA_attack,
					BEHA_attack_last,
					BEHA_attack_weak
		'WITH_*' is TODO!!
		'LVL'    is the skill level as a number (1-5) (default=5)
		'AAA'    is the "Alchemist Auto Attack" level as a number (default=0)
		         (-1 = OFF, 0 = Standard, 1 to 10 = the level)
	
	or a separator, in the form of a lua comment: (where 'Comment' is the name of the separator)
	
	-- Comment
#










