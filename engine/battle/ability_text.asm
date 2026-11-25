SECTION "Ability descriptions", ROMX, BANK[$3f]

; The banked renderer reads its ID from scratch; the pointer is 16-bit.
AbilityDrawDescriptionBanked:
	ld a, [wAbilityTemp]
	ld c, a
	ld b, 0
	sla c
	rl b
	ld hl, AbilityTextPointers
	add hl, bc
	ld a, [hli]
	ld d, [hl]
	ld e, a
	coord hl, 2, 4
	jp PlaceString

AbilityTextPointers:
	dw AbilityNone, AbilityPoisonLeaf, AbilityChlorophyll, AbilityOvergrowth, AbilityPhotosynthesisText, AbilityVineGuard
	dw AbilityBlaze, AbilityCombustion, AbilityWildfire, AbilityHotTemper, AbilityConfident
	dw AbilityText11
	dw AbilityText12
	dw AbilityText13
	dw AbilityText14
	dw AbilityText15
	dw AbilityText16
	dw AbilityText17
	dw AbilityText18
	dw AbilityText19
	dw AbilityText20
	dw AbilityText21
	dw AbilityText22
	dw AbilityText23
	dw AbilityText24
	dw AbilityText25
	dw AbilityText26
	dw AbilityText27
	dw AbilityText28
	dw AbilityText29
	dw AbilityText30
	dw AbilityText31
	dw AbilityText32
	dw AbilityText33
	dw AbilityText34
	dw AbilityText35, AbilityText36, AbilityText37, AbilityText38, AbilityText39, AbilityText40, AbilityText41, AbilityText42, AbilityText43, AbilityText44, AbilityText45
	dw AbilityText46, AbilityText47, AbilityText48
	dw AbilityText49, AbilityText50
	dw AbilityText51, AbilityText52, AbilityText53
	dw AbilityText54, AbilityText55, AbilityText56
	dw AbilityText57, AbilityText58, AbilityText59, AbilityText60
	dw AbilityText61, AbilityText62, AbilityText63, AbilityText64, AbilityText65
	dw AbilityText66, AbilityText67, AbilityText68, AbilityText69
	dw AbilityText70, AbilityText71, AbilityText72, AbilityText73
	dw AbilityText74, AbilityText75, AbilityText76, AbilityText77, AbilityText78
	dw AbilityText79, AbilityText80, AbilityText81, AbilityText82, AbilityText83
	dw AbilityText84, AbilityText85, AbilityText86
	dw AbilityText87, AbilityText88, AbilityText89, AbilityText90, AbilityText91, AbilityText92
	dw AbilityText93, AbilityText94, AbilityText95, AbilityText96, AbilityText97
	dw AbilityText98, AbilityText99, AbilityText100
	dw AbilityText101, AbilityText102, AbilityText103, AbilityText104, AbilityText105
	dw AbilityText106, AbilityText107, AbilityText108, AbilityText109
	dw AbilityText110, AbilityText111, AbilityText112, AbilityText113
	dw AbilityText114, AbilityText115, AbilityText116
	dw AbilityText117, AbilityText118, AbilityText119
	dw AbilityText120, AbilityText121, AbilityText122, AbilityText123, AbilityText124, AbilityText125
	dw AbilityText126, AbilityText127, AbilityText128, AbilityText129, AbilityText130, AbilityText131
	dw AbilityText132, AbilityText133, AbilityText134, AbilityText135, AbilityText136
	dw AbilityText137, AbilityText138, AbilityText139, AbilityText140, AbilityText141, AbilityText142
	dw AbilityText143, AbilityText144, AbilityText145, AbilityText146
	dw AbilityText147, AbilityText148, AbilityText149, AbilityText150
	dw AbilityText151, AbilityText152, AbilityText153, AbilityText154, AbilityText155, AbilityText156
	dw AbilityText157, AbilityText158, AbilityText159, AbilityText160, AbilityText161
	dw AbilityText162, AbilityText163, AbilityText164, AbilityText165
	dw AbilityText166, AbilityText167, AbilityText168, AbilityText169
	dw AbilityText170, AbilityText171, AbilityText172, AbilityText173, AbilityText174
	dw AbilityText175, AbilityText176, AbilityText177, AbilityText178, AbilityText179
	dw AbilityText180, AbilityText181, AbilityText182, AbilityText183
	dw AbilityText184, AbilityText185, AbilityText186, AbilityText187
	dw AbilityText188, AbilityText189, AbilityText190, AbilityText191
	dw AbilityText192, AbilityText193, AbilityText194, AbilityText195, AbilityText196, AbilityText197
	dw AbilityText198, AbilityText199, AbilityText200, AbilityText201, AbilityText202
	dw AbilityText203, AbilityText204, AbilityText205, AbilityText206
	dw AbilityText207, AbilityText208, AbilityText209
	dw AbilityText210, AbilityText211, AbilityText212, AbilityText213
	dw AbilityText214, AbilityText215, AbilityText216, AbilityText217, AbilityText218
	dw AbilityText219, AbilityText220, AbilityText221, AbilityText222, AbilityText223, AbilityText224
	dw AbilityText225, AbilityText226, AbilityText227, AbilityText228, AbilityText229
	dw AbilityText230, AbilityText231, AbilityText232, AbilityText233
	dw AbilityText234, AbilityText235, AbilityText236, AbilityText237
	dw AbilityText238, AbilityText239, AbilityText240, AbilityText241
	dw AbilityText242, AbilityText243, AbilityText244, AbilityText245
	dw AbilityText246, AbilityText247, AbilityText248, AbilityText249, AbilityText250
AbilityNone:
	db "NO ABILITY",$4e,"No ability pool",$4e,"for this species.@"
AbilityPoisonLeaf:
	db "POISON LEAF",$4e,"Grass hits have a",$4e,"25% poison odds.@"
AbilityChlorophyll:
	db "CHLOROPHYLL",$4e,"Speed x1.5 while",$4e,"HP is below 1/3.@"
AbilityOvergrowth:
	db "OVERGROWTH",$4e,"Grass power x1.25",$4e,"at full HP.@"
AbilityPhotosynthesisText:
	db "PHOTOSYNTHESIS",$4e,"Heal 1/16 HP each",$4e,"turn above 1/2.@"
AbilityVineGuard:
	db "VINE GUARD",$4e,"Flying damage",$4e,"received x0.5.@"
AbilityBlaze:
	db "BLAZE",$4e,"Fire power x1.25",$4e,"below 1/3 HP.@"
AbilityCombustion:
	db "COMBUSTION",$4e,"Non-Fire hits:",$4e,"15% burn chance.@"
AbilityWildfire:
	db "WILDFIRE",$4e,"Attack +1 when it",$4e,"burns an opponent.@"
AbilityHotTemper:
	db "HOT TEMPER",$4e,"Physical hit:",$4e,"Special +1 once",$4e,"per battle.@"
AbilityConfident:
	db "CONFIDENT",$4e,"After a miss:",$4e,"Accuracy +1 once",$4e,"per battle.@"

AbilityText11:
	db "WATER PRESSURE",$4e,"Water +2% per PP",$4e,"left, cap +50%.@"

AbilityText12:
	db "SHELL GUARD",$4e,"After a crit:",$4e,"Defense +1.@"

AbilityText13:
	db "ANCIENT",$4e,"Maximum HP x1.2.@"

AbilityText14:
	db "WATER VEIL",$4e,"Prevents burns.",$4e,"Fire damage",$4e,"x0.5.@"

AbilityText15:
	db "SHELL ARMOR",$4e,"Cannot be hit by",$4e,"critical hits.@"

AbilityText16:
	db "RUN AWAY",$4e,"Always escape",$4e,"wild battles.@"

AbilityText17:
	db "REPULSIVE",$4e,"Damaging hits:",$4e,"10% flinch odds.@"

AbilityText18:
	db "SURVIVAL INST.",$4e,"Below 1/3 HP:",$4e,"Speed +1 once",$4e,"per battle.@"

AbilityText19:
	db "QUICK REFLEXES",$4e,"First attack",$4e,"move each entry:",$4e,"priority +1.@"

AbilityText20:
	db "SHIELD DUST",$4e,"Blocks extra",$4e,"effects of",$4e,"moves.@"

AbilityText21:
	db "HARD SHELL",$4e,"Physical damage",$4e,"received x0.75.@"

AbilityText22:
	db "FORTIFY",$4e,"Below 1/3 HP:",$4e,"Defense +1 once",$4e,"per battle.@"

AbilityText23:
	db "REGENERATION",$4e,"Heal 1/16 max HP",$4e,"at each turn",$4e,"end.@"

AbilityText24:
	db "BATTLE ARMOR",$4e,"Cannot be hit by",$4e,"critical",$4e,"attacks.@"

AbilityText25:
	db "COMPOUND EYES",$4e,"Move accuracy",$4e,"multiplied x1.3.@"

AbilityText26:
	db "PSIONIC",$4e,"Psychic damage",$4e,"multiplied x1.2.@"

AbilityText27:
	db "DUST CLOUD",$4e,"Contact taken:",$4e,"25% lower foe",$4e,"Accuracy 1",$4e,"stage.@"

AbilityText28:
	db "WONDER SKIN",$4e,"Incoming status",$4e,"move accuracy",$4e,"multiplied x0.5.@"

AbilityText29:
	db "POISON POINT",$4e,"Contact taken:",$4e,"25% poison odds.@"

AbilityText30:
	db "VENOMOUS",$4e,"Damage x1.25 to",$4e,"poisoned foes.@"

AbilityText31:
	db "PIERCING STING",$4e,"Poison hits Bug",$4e,"at double power.@"

AbilityText32:
	db "TOXIC SHELL",$4e,"Contact taken:",$4e,"25% poison odds.@"

AbilityText33:
	db "RUTHLESS",$4e,"Crit odds x2 vs",$4e,"foes with",$4e,"status.@"

AbilityText34:
	db "FRENZY",$4e,"Direct move KO:",$4e,"Attack +1.@"

AbilityText35: db "STRONG JAW",$4e,"Physical damage",$4e,"x1.15.@"
AbilityText36: db "VOLTAGE",$4e,"Electric damage",$4e,"x1.2 vs paralysis.@"
AbilityText37: db "SNIPER",$4e,"Critical damage",$4e,"x1.5.@"
AbilityText38: db "SAND ARMOR",$4e,"Super effective",$4e,"damage x0.75.@"
AbilityText39: db "SHARP CLAWS",$4e,"Physical crit",$4e,"chance x1.5.@"
AbilityText40: db "CORNERED",$4e,"Below 1/3 HP:",$4e,"Attack +1 once.@"
AbilityText41: db "PREDATOR",$4e,"Physical damage",$4e,"x1.2 vs slower",$4e,"foes.@"
AbilityText42: db "KEEN EYE",$4e,"Accuracy cannot",$4e,"be lowered.@"
AbilityText43: db "TAILWIND",$4e,"Speed +1 on",$4e,"entry.@"
AbilityText44: db "GALE WINGS",$4e,"Flying priority",$4e,"+1 at full HP.@"
AbilityText45: db "PIERCING BEAK",$4e,"Flying ignores",$4e,"25% of Defense.@"
AbilityText46: db "SCAVENGER",$4e,"Direct KO heals",$4e,"1/4 max HP.@"
AbilityText47: db "HUSTLE",$4e,"Physical damage",$4e,"x1.25; accuracy",$4e,"-15 points.@"
AbilityText48: db "POISON HEAL",$4e,"Poison heals",$4e,"1/8 max HP.@"
AbilityText49: db "SHORT TEMPER",$4e,"Attack +1 when",$4e,"a move misses.@"
AbilityText50: db "RELENTLESS",$4e,"Each hit boosts",$4e,"next damage 10%",$4e,"up to 30%.@"
AbilityText51: db "INTIMIDATE",$4e,"Foe Speed -1 on",$4e,"entry, once.@"
AbilityText52: db "SHED SKIN",$4e,"30% chance to",$4e,"cure status at",$4e,"turn end.@"
AbilityText53: db "CORROSIVE VENOM",$4e,"Poison is strong",$4e,"against Rock.@"
AbilityText54: db "STATIC",$4e,"Physical hits:",$4e,"20% paralyze",$4e,"attacker.@"
AbilityText55: db "OVERCHARGE",$4e,"Critical hit:",$4e,"Special +1 once",$4e,"per battle.@"
AbilityText56: db "QUICK FEET",$4e,"Status raises",$4e,"Speed 1 stage.@"
AbilityText57: db "ROLLING DEFENSE",$4e,"Normal move:",$4e,"Defense +1 once",$4e,"per battle.@"
AbilityText58: db "BURROWER",$4e,"Ground move heals",$4e,"1/8 max HP.@"
AbilityText59: db "SAND VEIL",$4e,"Ground move:",$4e,"Evasion +1 once",$4e,"per battle.@"
AbilityText60: db "SPINY ARMOR",$4e,"Physical hits",$4e,"hurt attacker",$4e,"1/16 max HP.@"
AbilityText61: db "POISON POINT",$4e,"Physical hits:",$4e,"25% poison",$4e,"attacker.@"
AbilityText62: db "MEASURED",$4e,"Damage x0.8;",$4e,"extra effect",$4e,"chance x2.@"
AbilityText63: db "THICK HIDE",$4e,"Physical damage",$4e,"received x0.85.@"
AbilityText64: db "PROTECTIVE INST.",$4e,"Below 1/2 HP:",$4e,"Defense +1 once",$4e,"per battle.@"
AbilityText65: db "IRON WILL",$4e,"Cannot be hit by",$4e,"critical hits.@"
AbilityText66: db "PIERCING HORN",$4e,"Physical hits ignore",$4e,"20% of Defense.@"
AbilityText67: db "SHEER FORCE",$4e,"Secondary moves x1.2",$4e,"lose added effects.@"
AbilityText68: db "BLOODLUST",$4e,"Physical hits x1.25",$4e,"if foe below 1/2.@"
AbilityText69: db "RAMPAGE",$4e,"Physical hits x1.25",$4e,"recoil 10% damage.@"
AbilityText70: db "LUCKY STAR",$4e,"10% chance to deal",$4e,"50% more damage.@"
AbilityText71: db "MAGIC GUARD",$4e,"Blocks indirect",$4e,"damage.@"
AbilityText72: db "MOON CHILD",$4e,"Heal 1/16 max HP",$4e,"each turn.@"
AbilityText73: db "UNPREDICTABLE",$4e,"Metronome damage",$4e,"is boosted 30%.@"
AbilityText74: db "AFTERMATH",$4e,"Curse the foe that",$4e,"knocks this out.@"
AbilityText75: db "FOXFIRE",$4e,"Inflict burn:",$4e,"Special +1 once.@"
AbilityText76: db "NINE LIVES",$4e,"Survive a fatal hit",$4e,"once per battle.@"
AbilityText77: db "FOX'S CUNNING",$4e,"Ghost move: Evasion",$4e,"+1 once per battle.@"
AbilityText78: db "ILLUSION",$4e,"First attack taken",$4e,"is halved on entry.@"
AbilityText79: db "INFLATABLE",$4e,"Physical hit:",$4e,"Defense +1.@"
AbilityText80: db "PERFORMER",$4e,"Sound move accuracy",$4e,"is increased 20%.@"
AbilityText81: db "RUBBER SKIN",$4e,"Immune to Electric",$4e,"moves.@"
AbilityText82: db "SOOTHING VOICE",$4e,"Sound move: heal",$4e,"1/8 maximum HP.@"
AbilityText83: db "THICK FAT",$4e,"Fire and Ice damage",$4e,"is halved.@"
AbilityText84: db "ECHOLOCATION",$4e,"Move accuracy",$4e,"gains 20 points.@"
AbilityText85: db "BLOODSUCKER",$4e,"Drain moves heal an",$4e,"extra 25% damage.@"
AbilityText86: db "INFILTRATOR",$4e,"Bypasses screens",$4e,"and Substitute.@"
AbilityText87: db "PERFUME",$4e,"Evasion +1 when",$4e,"entering battle.@"
AbilityText88: db "ABSORPTION",$4e,"Drain moves heal an",$4e,"extra 25% damage.@"
AbilityText89: db "POLLEN",$4e,"Powder accuracy",$4e,"gains 20 points.@"
AbilityText90: db "EFFECT SPORE",$4e,"Physical hits: 20%",$4e,"poison, para or",$4e,"sleep.@"
AbilityText91: db "STENCH",$4e,"Poisoned foes deal",$4e,"25% less damage.@"
AbilityText92: db "TOXIC WASTE",$4e,"Heal 1/16 max HP",$4e,"if foe is poisoned.@"
AbilityText93: db "LEECHING",$4e,"Physical hits heal",$4e,"10% of damage.@"
AbilityText94: db "PARASITE",$4e,"Contact spreads",$4e,"this ability.@"
AbilityText95: db "MYCELIUM",$4e,"Status moves bypass",$4e,"accuracy checks.@"
AbilityText96: db "REGROWTH",$4e,"Heal 1/16 max HP",$4e,"each turn.@"
AbilityText97: db "DEATH SPORE",$4e,"When knocked out:",$4e,"curse or poison foe.@"
AbilityText98: db "TOXIC SCALES",$4e,"Physical hits: 30%",$4e,"chance to poison.@"
AbilityText99: db "TINTED LENS",$4e,"Resisted damage",$4e,"is doubled.@"
AbilityText100: db "POISON ABSORB",$4e,"Heal 1/8 max HP",$4e,"if foe is poisoned.@"
AbilityText101: db "AMBUSH",$4e,"First attack after",$4e,"entry deals x1.25.@"
AbilityText102: db "SUBTERRANEAN",$4e,"Super-effective",$4e,"damage x0.75.@"
AbilityText103: db "ELUSIVE",$4e,"Evasion +1 until",$4e,"attacked.@"
AbilityText104: db "AFTERSHOCK",$4e,"Ground hits: 20%",$4e,"chance to paralyze.@"
AbilityText105: db "SAND RUSH",$4e,"Ground move: Speed",$4e,"+1 once per battle.@"
AbilityText106: db "OPPORTUNIST",$4e,"Damage x1.2 if foe",$4e,"has lowered stats.@"
AbilityText107: db "GREEDY",$4e,"Doubles trainer",$4e,"prize money.@"
AbilityText108: db "RESOURCEFUL",$4e,"Moves gain 5 PP",$4e,"up to 63 maximum.@"
AbilityText109: db "TECHNICIAN",$4e,"Moves with power",$4e,"at most 60: x1.5.@"

AbilityText110: db "HEADACHE",$4e,"Special hit:",$4e,"Special +1 once.@"
AbilityText111: db "DAMP",$4e,"Explosion immune;",$4e,"Fire damage halved.@"
AbilityText112: db "CONFOUNDING",$4e,"Psychic hits may",$4e,"confuse the foe.@"
AbilityText113: db "UNSTABLE",$4e,"Below half HP:",$4e,"random stat +1.@"
AbilityText114: db "CLOUD NINE",$4e,"Foe cannot lower",$4e,"your stats.@"
AbilityText115: db "SWIFT SWIM",$4e,"Water hit raises",$4e,"Speed two stages.@"
AbilityText116: db "MIND READER",$4e,"Accuracy cannot",$4e,"be lowered.@"

AbilityText117: db "DEFIANT",$4e,"Status conditions",$4e,"do not lower stats.@"
AbilityText118: db "SCRAPPY",$4e,"Normal and Fighting",$4e,"moves hit Ghosts.@"
AbilityText119: db "UNSOPHISTICATED",$4e,"100% moves: power",$4e,"x1.25; accuracy -10.@"

AbilityText120: db "LOYALTY",$4e,"Heal 20% max HP",$4e,"after a knockout.@"
AbilityText121: db "LEGENDARY",$4e,"Moves with max PP",$4e,"10 or less: x1.25.@"
AbilityText122: db "MOMENTUM",$4e,"Recoil move: Speed",$4e,"+1 once per battle.@"
AbilityText123: db "STEADFAST",$4e,"Cannot be confused",$4e,"or flinched.@"
AbilityText124: db "ELEGANT MANE",$4e,"Special damage",$4e,"received x0.8.@"
AbilityText125: db "INTIMIDATE",$4e,"Entry: foe Speed",$4e,"-1 once per battle.@"

AbilityText126: db "HYPNOTIC",$4e,"Sleep moves:",$4e,"accuracy +15.@"
AbilityText127: db "SLIPPERY",$4e,"Physical hit:",$4e,"Evasion +1 once.@"
AbilityText128: db "HYDRATION",$4e,"Water move heals",$4e,"1/8 maximum HP.@"
AbilityText129: db "WRESTLER",$4e,"Fighting hits: 20%",$4e,"chance to paralyze.@"
AbilityText130: db "POWER SWIM",$4e,"Water move: Attack",$4e,"+1 once per battle.@"
AbilityText131: db "IRON FIST",$4e,"Punching moves",$4e,"deal 25% more.@"

AbilityText132: db "MENTAL SHIELD",$4e,"Special damage",$4e,"received x0.8.@"
AbilityText133: db "TELEPATHY",$4e,"Psychic move:",$4e,"Evasion +1 once.@"
AbilityText134: db "GENIUS",$4e,"Status moves:",$4e,"accuracy +15.@"
AbilityText135: db "MAGIC BOUNCE",$4e,"Reflects status",$4e,"moves at the foe.@"
AbilityText136: db "SPOON BENDER",$4e,"Psychic hits ignore",$4e,"20% of Special.@"

AbilityText137: db "NO GUARD",$4e,"Both sides' moves",$4e,"cannot miss.@"
AbilityText138: db "GUTS",$4e,"Status condition:",$4e,"Attack +1.@"
AbilityText139: db "IRON GRIP",$4e,"Physical damage",$4e,"x1.2 vs high Def.@"
AbilityText140: db "FOUR ARMS",$4e,"Multi-hit moves",$4e,"always hit maximum.@"
AbilityText141: db "GRAPPLER",$4e,"Physical hit: 10%",$4e,"foe Defense -1.@"
AbilityText142: db "BODYBUILDER",$4e,"Fighting move:",$4e,"Defense +1 once.@"

AbilityText143: db "ACIDIC",$4e,"Poison hit: 25%",$4e,"foe Defense -1.@"
AbilityText144: db "CARNIVOROUS",$4e,"Heal 20% max HP",$4e,"after a knockout.@"
AbilityText145: db "STICKY TRAP",$4e,"Physical hit: 20%",$4e,"foe Speed -1.@"
AbilityText146: db "DIGESTIVE ACID",$4e,"Poison power x1.25",$4e,"if foe Def > Spc.@"

AbilityText147: db "CLEAR BODY",$4e,"Foes cannot lower",$4e,"your stats.@"
AbilityText148: db "LIQUID OOZE",$4e,"Draining this mon",$4e,"hurts the attacker.@"
AbilityText149: db "STINGING SKIN",$4e,"Physical hit: 20%",$4e,"poisons attacker.@"
AbilityText150: db "JELLY BODY",$4e,"Physical damage",$4e,"received x0.8.@"

AbilityText151: db "LEVITATE",$4e,"Immune to Ground",$4e,"moves.@"
AbilityText152: db "IMMUNITY",$4e,"Cannot be poisoned.@"
AbilityText153: db "STURDY",$4e,"Survive lethal hit",$4e,"at full HP with 1.@"
AbilityText154: db "ROLLOUT",$4e,"Ground/Rock streak:",$4e,"power +10% each.@"
AbilityText155: db "HEAVYWEIGHT",$4e,"Rock damage x1.2",$4e,"if Defense is higher.@"
AbilityText156: db "DIGGER",$4e,"Damage x1.25 vs",$4e,"Ground types.@"

AbilityText157: db "FLAME BODY",$4e,"Physical hit: 20%",$4e,"burns attacker.@"
AbilityText158: db "COMPETITIVE",$4e,"Foe raises stat:",$4e,"Attack +1 once.@"
AbilityText159: db "BLAZING TRAIL",$4e,"Fire damage x1.2",$4e,"if faster than foe.@"
AbilityText160: db "WILD CHARGE",$4e,"Physical move:",$4e,"Speed +1 once.@"
AbilityText161: db "STAMINA",$4e,"When hit by an",$4e,"attack: Defense +1.@"

AbilityText162: db "OBLIVIOUS",$4e,"Cannot be confused",$4e,"or flinched.@"
AbilityText163: db "UNAWARE",$4e,"Ignores foe boosts",$4e,"when taking damage.@"
AbilityText164: db "PATIENT",$4e,"After foe acts:",$4e,"move damage x1.2.@"
AbilityText165: db "SIMPLE",$4e,"Stat changes are",$4e,"doubled.@"

AbilityText166: db "BATTERY",$4e,"Electric damage x1.2",$4e,"above half max PP.@"
AbilityText167: db "OVERLOAD",$4e,"Special hit: Special",$4e,"+1 once per battle.@"
AbilityText168: db "CHAIN REACTION",$4e,"Electric attack:",$4e,"next Electric x1.2.@"
AbilityText169: db "MAGNETIC FIELD",$4e,"Foe cannot raise",$4e,"Speed or Evasion.@"

AbilityText170: db "UNDERDOG",$4e,"Damage x1.2 if foe",$4e,"has higher base sum.@"
AbilityText171: db "UNYIELDING",$4e,"Foe cannot lower",$4e,"Attack or Defense.@"
AbilityText172: db "TASTY LEEK",$4e,"Critical hits heal",$4e,"1/10 maximum HP.@"
AbilityText173: db "PRECISION",$4e,"95 accuracy moves:",$4e,"100 accuracy, x1.2.@"
AbilityText174: db "RAZOR EDGE",$4e,"Cutting moves gain",$4e,"15% critical chance.@"

AbilityText175: db "TWIN BEAKS",$4e,"Move side effects",$4e,"odds are doubled.@"
AbilityText176: db "TRIPLE THREAT",$4e,"Multi-hit moves:",$4e,"at least 3 times.@"
AbilityText177: db "STAMPEDE",$4e,"Normal damage x1.2",$4e,"when faster.@"
AbilityText178: db "HEADSTRONG",$4e,"No confusion;",$4e,"Psychic taken x.75.@"
AbilityText179: db "RELENTLESS",$4e,"Streak: +10% each",$4e,"up to +30%.@"

AbilityText180: db "BLUBBER",$4e,"Fire damage x0.5;",$4e,"maximum HP x1.2.@"
AbilityText181: db "REFRIGERATE",$4e,"Normal attack: Ice",$4e,"type and power x1.2@"
AbilityText182: db "ICEBREAKER",$4e,"Ice moves are x2",$4e,"against Water.@"
AbilityText183: db "SNOW VEIL",$4e,"Ice move: Evasion",$4e,"+1 once per battle.@"

AbilityText184: db "CONTAMINATION",$4e,"Ground hits: 30%",$4e,"chance to poison.@"
AbilityText185: db "TOXIC WASTE",$4e,"Poison on field:",$4e,"heal 1/16 max HP.@"
AbilityText186: db "STICKY BODY",$4e,"Physical hit: 20%",$4e,"foe Speed -1.@"
AbilityText187: db "SOFT BODY",$4e,"Normal/Fighting",$4e,"damage taken x.75.@"

AbilityText188: db "SKILL LINK",$4e,"Multi-hit moves:",$4e,"maximum times.@"
AbilityText189: db "SPIKED SHELL",$4e,"Physical attacker",$4e,"loses 1/16 max HP.@"
AbilityText190: db "DEEPSEA PEARL",$4e,"Special damage",$4e,"received x0.8.@"
AbilityText191: db "LIQUIDATE",$4e,"Normal attacks:",$4e,"Water; damage x1.2@"

AbilityText192: db "GAS BODY",$4e,"Physical hit: 30%",$4e,"foe Accuracy -1.@"
AbilityText193: db "PRANKSTER",$4e,"Status moves gain",$4e,"+1 priority.@"
AbilityText194: db "NOCTURNAL",$4e,"Damage x1.2 vs",$4e,"sleeping foes.@"
AbilityText195: db "MIND GAMES",$4e,"Confuse foe:",$4e,"Special +1 once.@"
AbilityText196: db "CURSED TOUCH",$4e,"Physical hit: 20%",$4e,"curses attacker.@"
AbilityText197: db "CURSED BODY",$4e,"When hit: 30% to",$4e,"disable foe move.@"

AbilityText198: db "CRUSHING WEIGHT",$4e,"Rock damage x1.2",$4e,"if Defense higher.@"
AbilityText199: db "COLOSSAL SIZE",$4e,"Max HP x1.25;",$4e,"Speed x0.75.@"
AbilityText200: db "STURDY",$4e,"Survive full-HP KO",$4e,"at 1 HP, once.@"
AbilityText201: db "EARTHSHAKER",$4e,"Ground hit: 20%",$4e,"foe Speed -1.@"
AbilityText202: db "EARTH EATER",$4e,"Ground attacks heal",$4e,"1/4 maximum HP.@"

AbilityText203: db "NIGHTMARE",$4e,"Sleeping foe loses",$4e,"1/16 HP per turn.@"
AbilityText204: db "SANDMAN",$4e,"Ground hit: 20%",$4e,"puts foe to sleep.@"
AbilityText205: db "DEEP SLEEP",$4e,"Sleep inflicted",$4e,"lasts +1 turn.@"
AbilityText206: db "DREAMCATCHER",$4e,"Put foe to sleep:",$4e,"heal 1/8 max HP.@"

AbilityText207: db "CRUSHING CLAWS",$4e,"Physical hit: 20%",$4e,"foe Defense -1.@"
AbilityText208: db "BRUTE FORCE",$4e,"Physical moves at",$4e,"60 or less: x1.3.@"
AbilityText209: db "HYPER CUTTER",$4e,"Attack cannot fall;",$4e,"crit damage x1.25.@"

AbilityText210: db "HIGH VOLTAGE",$4e,"Electric damage x1.2",$4e,"vs slower foes.@"
AbilityText211: db "SHORT CIRCUIT",$4e,"Electric hits: 15%",$4e,"confuse foe.@"
AbilityText212: db "VOLATILE",$4e,"Direct KO: foe loses",$4e,"1/5 max HP.@"
AbilityText213: db "CHAIN REACTION",$4e,"Electric streak:",$4e,"+20%, max +40%.@"

AbilityText214: db "COLLECTIVE MIND",$4e,"Psychic hits: 20%",$4e,"confuse foe.@"
AbilityText215: db "EXECUTIONER",$4e,"Physical hits x1.25",$4e,"vs foe below half.@"
AbilityText216: db "HARVEST",$4e,"Grass move: heal",$4e,"1/8 max HP.@"
AbilityText217: db "SOLAR POWER",$4e,"Grass damage x1.25",$4e,"above half HP.@"
AbilityText218: db "THICK TRUNK",$4e,"Physical hits x0.8;",$4e,"blocks criticals.@"

AbilityText219: db "LONELY",$4e,"Below 1/3 HP:",$4e,"Defense +1 once.@"
AbilityText220: db "THICK SKULL",$4e,"Physical damage",$4e,"received x0.8.@"
AbilityText221: db "ROCK HEAD",$4e,"Prevents recoil",$4e,"damage.@"
AbilityText222: db "BONE COLLECTOR",$4e,"Direct KO heals",$4e,"1/8 max HP.@"
AbilityText223: db "BONE BREAKER",$4e,"Physical hits ignore",$4e,"20% of Defense.@"
AbilityText224: db "VENGEFUL",$4e,"Below 1/3 HP:",$4e,"Attack +1 once.@"

AbilityText225: db "RECKLESS",$4e,"Recoil and crash",$4e,"moves deal x1.25.@"
AbilityText226: db "RESILIENCE",$4e,"First super effect.",$4e,"attack damage x0.25.@"
AbilityText227: db "FOOTWORK",$4e,"Fighting move:",$4e,"Evasion +1 once.@"
AbilityText228: db "LONG LEGS",$4e,"Kicking moves",$4e,"deal x1.25 damage.@"
AbilityText229: db "LIMBER",$4e,"No paralysis;",$4e,"Speed x1.2.@"

AbilityText230: db "SECOND WIND",$4e,"Below 1/3 HP: heal",$4e,"1/4 max HP once.@"
AbilityText231: db "COMBOS",$4e,"Punch streak +10%",$4e,"each, max +30%.@"
AbilityText232: db "COUNTERPUNCH",$4e,"Physical hit:",$4e,"Attack +1 once.@"
AbilityText233: db "GUARD UP",$4e,"Physical damage",$4e,"received x0.8.@"

AbilityText234: db "GLUTTONY",$4e,"Normal attack: heal",$4e,"1/8 max HP.@"
AbilityText235: db "THICK TONGUE",$4e,"Normal moves deal",$4e,"x1.3 damage.@"
AbilityText236: db "SLOBBER",$4e,"Physical hits: 15%",$4e,"confuse foe.@"
AbilityText237: db "BOTTOMLESS STOMACH",$4e,"Maximum HP x1.2.@"

AbilityText238: db "TOXIC FUMES",$4e,"Poison hits: 20%",$4e,"badly poison foe.@"
AbilityText239: db "GAS LEAK",$4e,"Foe loses 1/16 HP",$4e,"at turn end.@"
AbilityText240: db "CHEMICAL REACTION",$4e,"Fire hit: Special",$4e,"+1 once.@"
AbilityText241: db "NEUTRALIZING GAS",$4e,"Suppresses foe",$4e,"ability while active.@"

AbilityText242: db "CHARGE",$4e,"First physical move",$4e,"each entry: x1.3.@"
AbilityText243: db "ARMORED",$4e,"Physical damage",$4e,"received x0.8.@"
AbilityText244: db "SOLID ROCK",$4e,"Super-effective",$4e,"damage x0.75.@"
AbilityText245: db "HORN BREAKER",$4e,"Horn attacks deal",$4e,"x1.25 damage.@"

AbilityText246: db "NATURAL CURE",$4e,"Switch out: cure",$4e,"major status.@"
AbilityText247: db "SERENE GRACE",$4e,"Move extra effect",$4e,"chance x2.@"
AbilityText248: db "TRIAGE",$4e,"Healing moves:",$4e,"priority +3.@"
AbilityText249: db "HEALER",$4e,"Switch out: heal",$4e,"next ally 10%.@"
AbilityText250: db "LUCKY",$4e,"Critical damage",$4e,"received x0.5.@"
