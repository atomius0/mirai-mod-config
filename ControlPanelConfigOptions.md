## Mapping of original MirAI CP options to Config.lua variables:

### Auto Aid Potion (Potion Pitcher) Support:

#### First dropdown menu:
- Disabled:                              AAP.Mode=0
- Support evasive maneuvers:             AAP.Mode=1
- Support attacks:                       AAP.Mode=2
- Support attacks and evasive maneuvers: AAP.Mode=3
- Support everytime (in idle mode too):  AAP.Mode=4

#### Second dropdown menu:
- Throw Red Potions (lvl 1):    AAP.Level=1
- Throw Orange Potions (lvl 2): AAP.Level=2
- Throw Yellow Potions (lvl 3): AAP.Level=3
- Throw White Potions (lvl 4):  AAP.Level=4

#### Slider "When homunculus HPs are less than:"
- AAP.HP_Perc=X  (X is the slider's percentage) (0-100)


### Homunculus Attack and Evade:

- Attack when HPs >: HP_PERC_SAFE2ATK=X  (X is the slider's percentage) (0-100)
- Evade when HP <:   HP_PERC_DANGER=X    (X is the slider's percentage) (0-100)

The two sliders above are linked. the following is always true:
- Attack >= Evade
- Evade  <= Attack

eg: When the user tries to lower the Attack slider below the Evade slider, Evade will follow automatically.

And when the user tries to raise the Evade slider above the Attack slider, Attack will follow, too.


#### Checkbox: "CB_DontChase"
- [x]:  LONG_RANGE_SHOOTER=true
- [ ]:  LONG_RANGE_SHOOTER=false

#### Checkbox: "Cautious"
- [x]:  DEFAULT_BEHA = BEHA_react
- [ ]:  DEFAULT_BEHA = BEHA_attack

#### Checkbox: "Switch target"
- [x]:  HELP_OWNER_1ST=true
- [ ]:  HELP_OWNER_1ST=false

