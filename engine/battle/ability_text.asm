SECTION "Ability descriptions", ROMX, BANK[$3f]

; The banked renderer reads its ID from scratch; the pointer is 16-bit.
AbilityDrawDescriptionBanked:
	ld a, [wAbilityTemp]
	cp ABILITY_EXTENDED
	jr nz, .ordinary
	ld a, [wAbilityResolvedExtended]
	and a
	jr z, .none
	dec a
	ld c, a
	ld b, 1
	jr .index
.none
	xor a
.ordinary
	ld c, a
	ld b, 0
.index
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
	dw AbilityText251
	dw AbilityNone, AbilityNone, AbilityNone, AbilityNone ; 252..255 reserved
	dw AbilityText252 ; extended ID 256
	dw AbilityText257, AbilityText258, AbilityText259, AbilityText260
	dw AbilityText261, AbilityText262, AbilityText263, AbilityText264
	dw AbilityText265, AbilityText266
	dw AbilityText267, AbilityText268, AbilityText269, AbilityText270
	dw AbilityText271, AbilityText272, AbilityText273
	dw AbilityText274, AbilityText275, AbilityText276
	dw AbilityText277, AbilityText278, AbilityText279, AbilityText280
	dw AbilityText281, AbilityText282, AbilityText283, AbilityText284, AbilityText285
	dw AbilityText286, AbilityText287, AbilityText288, AbilityText289
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

AbilityText251: db "ENTANGLE",$4e,"Grass hit: 30%",$4e,"foe Speed -1.@"
AbilityText252: db "THICK VINES",$4e,"Physical damage",$4e,"dealt x1.2.@"

AbilityText257: db "PARENTAL BOND",$4e,"Second hit deals",$4e,"1/4 first damage.@"
AbilityText258: db "HEAVY HITTER",$4e,"Physical hits x1.2",$4e,"when moving second.@"
AbilityText259: db "EARLY BIRD",$4e,"Sleep duration",$4e,"is halved.@"
AbilityText260: db "MATERNAL RAGE",$4e,"Below half HP:",$4e,"Attack +1 once.@"

AbilityText261: db "INK CLOUD",$4e,"Physical hit:",$4e,"Evasion +1 once.@"
AbilityText262: db "WATER JET",$4e,"Water hit: 20%",$4e,"foe Speed -1.@"
AbilityText263: db "FOCUSED",$4e,"First move if attack:",$4e,"damage x1.2.@"
AbilityText264: db "TOXIC SPINES",$4e,"Physical hit: 25%",$4e,"poisons attacker.@"

AbilityText265: db "ROYAL HORN",$4e,"Horn moves: crit",$4e,"chance +25 points.@"
AbilityText266: db "LIGHTNING ROD",$4e,"Immune to Electric",$4e,"moves.@"

AbilityText267: db "REGENERATOR",$4e,"Switch out: heal",$4e,"1/4 max HP.@"
AbilityText268: db "COSMIC CORE",$4e,"Special damage",$4e,"received x0.8.@"
AbilityText269: db "ILLUMINATE",$4e,"Move accuracy",$4e,"+15 points.@"
AbilityText270: db "EQUALIZER",$4e,"Resisted attacks",$4e,"deal neutral damage.@"

AbilityText271: db "COPYCAT",$4e,"Copies foe stat",$4e,"increases.@"
AbilityText272: db "STRONGMAN",$4e,"Physical moves use",$4e,"Special as Attack.@"
AbilityText273: db "MIRROR ARMOR",$4e,"Reflects stat",$4e,"reductions.@"
AbilityText274: db "SHARP BLADES",$4e,"Cutting moves deal",$4e,"x1.25 damage.@"
AbilityText275: db "VANGUARD",$4e,"First attack each",$4e,"entry: priority +1.@"
AbilityText276: db "DOUBLE SCYTHES",$4e,"Cutting moves: 20%",$4e,"chance of half hit.@"
AbilityText277: db "DANCER",$4e,"Status move: Speed",$4e,"+1 once per battle.@"
AbilityText278: db "COLD TOUCH",$4e,"Physical hit: 20%",$4e,"foe Speed -1.@"
AbilityText279: db "ENCHANTRESS",$4e,"Psychic hit: 20%",$4e,"confuses foe.@"
AbilityText280: db "ICE QUEEN",$4e,"Ice moves x1.25",$4e,"above half HP.@"
AbilityText281: db "POWER SURGE",$4e,"Electric moves x1.15",$4e,"above half HP.@"
AbilityText282: db "ENERGY DRAIN",$4e,"Electric move: heal",$4e,"1/8 max HP.@"
AbilityText283: db "THUNDERSTRUCK",$4e,"Electric hit: 20%",$4e,"confuses foe.@"
AbilityText284: db "LIVE WIRE",$4e,"Electric move:",$4e,"Attack +1 once.@"
AbilityText285: db "GALVANIZE",$4e,"Normal moves become",$4e,"Electric type.@"
AbilityText286: db "FLAME BODY",$4e,"Physical hit: 25%",$4e,"burns attacker.@"
AbilityText287: db "MAGMA ARMOR",$4e,"Prevents freeze;",$4e,"Ice damage x0.5.@"
AbilityText288: db "VITAL HEAT",$4e,"Fire move: heal",$4e,"1/8 max HP.@"
AbilityText289: db "BURNING RAGE",$4e,"Damage x1.25 vs",$4e,"burned foe.@"

; Five byte-sized slots per pool, read across banks.
AbilityPoolIds:
	db AB_POISON_LEAF, AB_CHLOROPHYLL, AB_OVERGROWTH, AB_PHOTOSYNTHESIS, AB_VINE_GUARD
	db AB_BLAZE, AB_COMBUSTION, AB_WILDFIRE, AB_HOT_TEMPER, AB_CONFIDENT
	db AB_WATER_PRESSURE, AB_SHELL_GUARD, AB_ANCIENT, AB_WATER_VEIL, AB_SHELL_ARMOR
	db AB_RUN_AWAY, AB_REPULSIVE, AB_SURVIVAL_INSTINCTS, AB_QUICK_REFLEXES, AB_SHIELD_DUST
	db AB_HARD_SHELL, AB_FORTIFY, AB_REGENERATION, AB_QUICK_REFLEXES, AB_BATTLE_ARMOR
	db AB_COMPOUND_EYES, AB_PSIONIC, AB_DUST_CLOUD, AB_QUICK_REFLEXES, AB_WONDER_SKIN
	db AB_POISON_POINT, AB_REPULSIVE, AB_VENOMOUS, AB_PIERCING_STING, AB_SHIELD_DUST
	db AB_HARD_SHELL, AB_FORTIFY, AB_TOXIC_SHELL, AB_PIERCING_STING, AB_BATTLE_ARMOR
	db AB_RUTHLESS, AB_FRENZY, AB_VENOMOUS, AB_PIERCING_STING, AB_QUICK_REFLEXES
	db AB_TAILWIND, AB_PREDATOR, AB_KEEN_EYE, AB_PIERCING_BEAK, AB_GALE_WINGS
	db AB_SCAVENGER, AB_STRONG_JAW, AB_CORNERED, AB_HUSTLE, AB_POISON_HEAL
	db AB_RUTHLESS, AB_SHORT_TEMPER, AB_RELENTLESS, AB_PIERCING_BEAK, AB_SNIPER
	db AB_INTIMIDATE, AB_SHED_SKIN, AB_VENOMOUS, AB_PREDATOR, AB_CORROSIVE_VENOM
	db AB_STATIC, AB_VOLTAGE, AB_OVERCHARGE, AB_QUICK_REFLEXES, AB_QUICK_FEET
	db AB_ROLLING_DEFENSE, AB_SAND_ARMOR, AB_BURROWER, AB_SHARP_CLAWS, AB_SAND_VEIL
	db AB_SPINY_ARMOR, AB_SAND_ARMOR, AB_BURROWER, AB_SHARP_CLAWS, AB_SAND_VEIL
	db AB_PHYSICAL_POISON_POINT, AB_MEASURED, AB_THICK_HIDE, AB_PROTECTIVE_INSTINCT, AB_IRON_WILL
	db AB_PHYSICAL_POISON_POINT, AB_PIERCING_HORN, AB_SHEER_FORCE, AB_BLOODLUST, AB_RAMPAGE
	db AB_LUCKY_STAR, AB_MAGIC_GUARD, AB_MOON_CHILD, AB_UNPREDICTABLE, AB_WONDER_SKIN
	db AB_AFTERMATH, AB_FOXFIRE, AB_NINE_LIVES, AB_FOXS_CUNNING, AB_ILLUSION
	db AB_INFLATABLE, AB_PERFORMER, AB_RUBBER_SKIN, AB_SOOTHING_VOICE, AB_THICK_FAT
	db AB_ECHOLOCATION, AB_BLOODSUCKER, AB_GALE_WINGS, AB_INFILTRATOR, AB_PREDATOR
	db AB_PERFUME, AB_ABSORPTION, AB_POLLEN, AB_EFFECT_SPORE, AB_PHOTOSYNTHESIS
	db AB_STENCH, AB_ABSORPTION, AB_POLLEN, AB_EFFECT_SPORE, AB_TOXIC_WASTE
	db AB_EFFECT_SPORE, AB_LEECHING, AB_PARASITE, AB_MYCELIUM, AB_REGROWTH
	db AB_EFFECT_SPORE, AB_LEECHING, AB_PARASITE, AB_MYCELIUM, AB_DEATH_SPORE
	db AB_SHIELD_DUST, AB_TOXIC_SCALES, AB_TINTED_LENS, AB_POISON_ABSORB, AB_VENOMOUS
	db AB_AMBUSH, AB_SUBTERRANEAN, AB_ELUSIVE, AB_AFTERSHOCK, AB_SAND_RUSH
	db AB_OPPORTUNIST, AB_GREEDY, AB_RESOURCEFUL, AB_QUICK_REFLEXES, AB_TECHNICIAN
	db AB_HEADACHE, AB_PSIONIC, AB_DAMP, AB_CONFOUNDING, AB_UNSTABLE
	db AB_CLOUD_NINE, AB_SWIFT_SWIM, AB_DAMP, AB_MIND_READER, AB_WATER_VEIL
	db AB_DEFIANT, AB_SHORT_TEMPER, AB_SCRAPPY, AB_UNSOPHISTICATED, AB_BLOODLUST
	db AB_LOYALTY, AB_MOMENTUM, AB_STEADFAST, AB_GROWL_INTIMIDATE, AB_ELEGANT_MANE
	db AB_LEGENDARY, AB_MOMENTUM, AB_STEADFAST, AB_GROWL_INTIMIDATE, AB_ELEGANT_MANE
	db AB_HYPNOTIC, AB_SLIPPERY, AB_SWIFT_SWIM, AB_HYDRATION, AB_WATER_VEIL
	db AB_WRESTLER, AB_SLIPPERY, AB_SWIFT_SWIM, AB_POWER_SWIM, AB_IRON_FIST
	db AB_RUN_AWAY, AB_MENTAL_SHIELD, AB_TELEPATHY, AB_GENIUS, AB_MAGIC_BOUNCE
	db AB_SPOON_BENDER, AB_MAGIC_GUARD, AB_MIND_READER, AB_GENIUS, AB_MAGIC_BOUNCE
	db AB_NO_GUARD, AB_GUTS, AB_IRON_GRIP, AB_GRAPPLER, AB_BODYBUILDER
	db AB_NO_GUARD, AB_GUTS, AB_FOUR_ARMS, AB_GRAPPLER, AB_BODYBUILDER
	db AB_ACIDIC, AB_CARNIVOROUS, AB_STICKY_TRAP, AB_CHLOROPHYLL, AB_DIGESTIVE_ACID
	db AB_CLEAR_BODY, AB_LIQUID_OOZE, AB_STINGING_SKIN, AB_JELLY_BODY, AB_VENOMOUS
	db AB_LEVITATE, AB_IMMUNITY, AB_STURDY, AB_ROLLOUT, AB_HEAVYWEIGHT
	db AB_DIGGER, AB_IMMUNITY, AB_STURDY, AB_ROLLOUT, AB_HEAVYWEIGHT
	db AB_FLAME_BODY, AB_COMPETITIVE, AB_BLAZING_TRAIL, AB_WILD_CHARGE, AB_STAMINA
	db AB_SHELL_ARMOR, AB_OBLIVIOUS, AB_UNAWARE, AB_PATIENT, AB_SIMPLE
	db AB_LEVITATE, AB_BATTERY, AB_OVERLOAD, AB_CHAIN_REACTION, AB_MAGNETIC_FIELD
	db AB_UNDERDOG, AB_UNYIELDING, AB_TASTY_LEEK, AB_PRECISION, AB_RAZOR_EDGE
	db AB_TWIN_BEAKS, AB_STAMPEDE, AB_QUICK_FEET, AB_BIRD_RELENTLESS, AB_HEADSTRONG
	db AB_TRIPLE_THREAT, AB_STAMPEDE, AB_QUICK_FEET, AB_BIRD_RELENTLESS, AB_HEADSTRONG
	db AB_BLUBBER, AB_HYDRATION, AB_REFRIGERATE, AB_ICEBREAKER, AB_SNOW_VEIL
	db AB_CONTAMINATION, AB_GRIMER_TOXIC_WASTE, AB_STICKY_BODY, AB_LIQUID_OOZE, AB_SOFT_BODY
	db AB_SHELL_ARMOR, AB_SKILL_LINK, AB_SPIKED_SHELL, AB_DEEPSEA_PEARL, AB_LIQUIDATE
	db AB_LEVITATE, AB_GAS_BODY, AB_PRANKSTER, AB_NOCTURNAL, AB_MIND_GAMES
	db AB_LEVITATE, AB_CURSED_TOUCH, AB_PRANKSTER, AB_CURSED_BODY, AB_MIND_GAMES
	db AB_CRUSHING_WEIGHT, AB_COLOSSAL_SIZE, AB_ONIX_STURDY, AB_EARTHSHAKER, AB_EARTH_EATER
	db AB_NIGHTMARE, AB_SANDMAN, AB_DEEP_SLEEP, AB_DREAMCATCHER, AB_MENTAL_SHIELD
	db AB_CRUSHING_CLAWS, AB_SHELL_ARMOR, AB_BRUTE_FORCE, AB_WATER_PRESSURE, AB_HYPER_CUTTER
	db AB_HIGH_VOLTAGE, AB_SHORT_CIRCUIT, AB_VOLATILE, AB_UNSTABLE, AB_VOLTORB_CHAIN
	db AB_COLLECTIVE_MIND, AB_EXECUTIONER, AB_HARVEST, AB_IMMUNITY, AB_SOLAR_POWER
	db AB_COLLECTIVE_MIND, AB_THICK_TRUNK, AB_HARVEST, AB_IMMUNITY, AB_SOLAR_POWER
	db AB_LONELY, AB_THICK_SKULL, AB_ROCK_HEAD, AB_UNDERDOG, AB_BONE_BREAKER
	db AB_VENGEFUL, AB_THICK_SKULL, AB_ROCK_HEAD, AB_BONE_COLLECTOR, AB_BONE_BREAKER
	db AB_RECKLESS, AB_RESILIENCE, AB_FOOTWORK, AB_LONG_LEGS, AB_LIMBER
	db AB_IRON_FIST, AB_SECOND_WIND, AB_COMBOS, AB_COUNTERPUNCH, AB_GUARD_UP
	db AB_GLUTTONY, AB_POISON_HEAL, AB_THICK_TONGUE, AB_SLOBBER, AB_BOTTOMLESS_STOMACH
	db AB_LEVITATE, AB_TOXIC_FUMES, AB_GAS_LEAK, AB_CHEMICAL_REACTION, AB_NEUTRALIZING_GAS
	db AB_CHARGE, AB_ARMORED, AB_SOLID_ROCK, AB_ROCK_HEAD, AB_HORN_BREAKER
	db AB_NATURAL_CURE, AB_SERENE_GRACE, AB_TRIAGE, AB_HEALER, AB_LUCKY
	db AB_ENTANGLE, AB_REGROWTH, AB_VINE_GUARD, ABILITY_EXTENDED, AB_DAMP
	db ABILITY_EXTENDED, AB_SCRAPPY, ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED
	db AB_SNIPER, ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED
	db ABILITY_EXTENDED, AB_SWIFT_SWIM, AB_WATER_VEIL, AB_HORN_BREAKER, ABILITY_EXTENDED
	db ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED, AB_NATURAL_CURE, ABILITY_EXTENDED
	db ABILITY_EXTENDED, AB_PRANKSTER, AB_MAGIC_BOUNCE, ABILITY_EXTENDED, ABILITY_EXTENDED
	db AB_TECHNICIAN, ABILITY_EXTENDED, ABILITY_EXTENDED, AB_EXECUTIONER, ABILITY_EXTENDED
	db ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED, AB_SNOW_VEIL
	db ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED
	db ABILITY_EXTENDED, AB_HOT_TEMPER, ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED


; Species-to-pool lookup is banked with the pool data.
AbilityFamilyBanked:
 ld a, [wAbilityResolvedExtended]
 ld b, a
 ld hl, AbilitySpeciesPools
.loop
 ld a, [hli]
 and a
 jr z, .store
 cp b
 ld a, [hli]
 jr nz, .loop
.store
 ld [wAbilityResolvedExtended], a
 ret

AbilitySpeciesPools:
	db BULBASAUR, 1
	db IVYSAUR, 1
	db VENUSAUR, 1
	db CHARMANDER, 2
	db CHARMELEON, 2
	db CHARIZARD, 2
	db SQUIRTLE, 3
	db WARTORTLE, 3
	db BLASTOISE, 3
	db CATERPIE, 4
	db METAPOD, 5
	db BUTTERFREE, 6
	db WEEDLE, 7
	db KAKUNA, 8
	db BEEDRILL, 9
	db PIDGEY, 10
	db PIDGEOTTO, 10
	db PIDGEOT, 10
	db RATTATA, 11
	db RATICATE, 11
	db SPEAROW, 12
	db FEAROW, 12
	db EKANS, 13
	db ARBOK, 13
	db PIKACHU, 14
	db RAICHU, 14
	db SANDSHREW, 15
	db SANDSLASH, 16
	db NIDORAN_F, 17
	db NIDORINA, 17
	db NIDOQUEEN, 17
	db NIDORAN_M, 18
	db NIDORINO, 18
	db NIDOKING, 18
	db CLEFAIRY, 19
	db CLEFABLE, 19
	db VULPIX, 20
	db NINETALES, 20
	db JIGGLYPUFF, 21
	db WIGGLYTUFF, 21
	db ZUBAT, 22
	db GOLBAT, 22
	db CROBAT, 22
	db ODDISH, 23
	db GLOOM, 24
	db VILEPLUME, 23
	db PARAS, 25
	db PARASECT, 26
	db VENONAT, 27
	db VENOMOTH, 27
	db DIGLETT, 28
	db DUGTRIO, 28
	db MEOWTH, 29
	db PERSIAN, 29
	db PSYDUCK, 30
	db GOLDUCK, 31
	db MANKEY, 32
	db PRIMEAPE, 32
	db GROWLITHE, 33
	db ARCANINE, 34
	db POLIWAG, 35
	db POLIWHIRL, 35
	db POLIWRATH, 36
	db ABRA, 37
	db KADABRA, 38
	db ALAKAZAM, 38
	db MACHOP, 39
	db MACHOKE, 39
	db MACHAMP, 40
	db BELLSPROUT, 41
	db WEEPINBELL, 41
	db VICTREEBEL, 41
	db TENTACOOL, 42
	db TENTACRUEL, 42
	db GEODUDE, 43
	db GRAVELER, 44
	db GOLEM, 44
	db PONYTA, 45
	db RAPIDASH, 45
	db SLOWPOKE, 46
	db SLOWBRO, 46
	db MAGNEMITE, 47
	db MAGNETON, 47
	db FARFETCHD, 48
	db DODUO, 49
	db DODRIO, 50
	db SEEL, 51
	db DEWGONG, 51
	db GRIMER, 52
	db MUK, 52
	db SHELLDER, 53
	db CLOYSTER, 53
	db GASTLY, 54
	db HAUNTER, 55
	db GENGAR, 55
	db ONIX, 56
	db DROWZEE, 57
	db HYPNO, 57
	db KRABBY, 58
	db KINGLER, 58
	db VOLTORB, 59
	db ELECTRODE, 59
	db EXEGGCUTE, 60
	db EXEGGUTOR, 61
	db CUBONE, 62
	db MAROWAK, 63
	db HITMONLEE, 64
	db HITMONCHAN, 65
	db LICKITUNG, 66
	db KOFFING, 67
	db WEEZING, 67
	db RHYHORN, 68
	db RHYDON, 68
	db CHANSEY, 69
	db TANGELA, 70
	db KANGASKHAN, 71
	db HORSEA, 72
	db SEADRA, 72
	db GOLDEEN, 73
	db SEAKING, 73
	db STARYU, 74
	db STARMIE, 74
	db MR_MIME, 75
	db SCYTHER, 76
	db JYNX, 77
	db ELECTABUZZ, 78
	db MAGMAR, 79
	db 0

; Shared battle move flags live with the banked ability data.
INCLUDE "data/ability_move_metadata.asm"

; B carries the bank during the call; recover the saved slot from scratch.
AbilityFindExtendedPool:
 ld a, [wAbilityTemp]
 ld c, a
 ld a, [wAbilityResolvedExtended]
 ld b, a
 xor a
 ld [wAbilityResolvedExtended], a
 ld hl, AbilityExtendedPoolIds
.find
 ld a, [hli]
 and a
 ret z
 cp c
 jr nz, .next
 ld a, [hli]
 cp b
 jr z, .found
 inc hl
 jr .find
.next
 inc hl
 inc hl
 jr .find
.found
 ld a, [hl]
 ld [wAbilityResolvedExtended], a
 ret

AbilityExtendedPoolIds:
 db 70, 4, AB_THICK_VINES - ABILITY_EXTENDED
 db 71, 1, AB_PARENTAL_BOND - ABILITY_EXTENDED
 db 71, 3, AB_HEAVY_HITTER - ABILITY_EXTENDED
 db 71, 4, AB_EARLY_BIRD - ABILITY_EXTENDED
 db 71, 5, AB_MATERNAL_RAGE - ABILITY_EXTENDED
 db 72, 2, AB_INK_CLOUD - ABILITY_EXTENDED
 db 72, 3, AB_WATER_JET - ABILITY_EXTENDED
 db 72, 4, AB_FOCUSED - ABILITY_EXTENDED
 db 72, 5, AB_TOXIC_SPINES - ABILITY_EXTENDED
 db 73, 1, AB_ROYAL_HORN - ABILITY_EXTENDED
 db 73, 5, AB_LIGHTNING_ROD - ABILITY_EXTENDED
 db 74, 1, AB_REGENERATOR - ABILITY_EXTENDED
 db 74, 2, AB_COSMIC_CORE - ABILITY_EXTENDED
 db 74, 3, AB_ILLUMINATE - ABILITY_EXTENDED
 db 74, 5, AB_EQUALIZER - ABILITY_EXTENDED
 db 75, 1, AB_COPYCAT - ABILITY_EXTENDED
 db 75, 4, AB_STRONGMAN - ABILITY_EXTENDED
 db 75, 5, AB_MIRROR_ARMOR - ABILITY_EXTENDED
 db 76, 2, AB_SHARP_BLADES - ABILITY_EXTENDED
 db 76, 3, AB_VANGUARD - ABILITY_EXTENDED
 db 76, 5, AB_DOUBLE_SCYTHES - ABILITY_EXTENDED
 db 77, 1, AB_DANCER - ABILITY_EXTENDED
 db 77, 2, AB_COLD_TOUCH - ABILITY_EXTENDED
 db 77, 3, AB_ENCHANTRESS - ABILITY_EXTENDED
 db 77, 4, AB_ICE_QUEEN - ABILITY_EXTENDED
 db 78, 1, AB_POWER_SURGE - ABILITY_EXTENDED
 db 78, 2, AB_ENERGY_DRAIN - ABILITY_EXTENDED
 db 78, 3, AB_THUNDERSTRUCK - ABILITY_EXTENDED
 db 78, 4, AB_LIVE_WIRE - ABILITY_EXTENDED
 db 78, 5, AB_GALVANIZE - ABILITY_EXTENDED
 db 79, 1, AB_MAGMAR_FLAME_BODY - ABILITY_EXTENDED
 db 79, 3, AB_MAGMA_ARMOR - ABILITY_EXTENDED
 db 79, 4, AB_VITAL_HEAT - ABILITY_EXTENDED
 db 79, 5, AB_BURNING_RAGE - ABILITY_EXTENDED
 db 0


AbilityBounceMoveBanked:
 ld a, [wAbilityResolvedExtended]
 ld hl, AbilityBounceMoves
 ld de, 1
 jp IsInArray

AbilityBounceMoves:
 db WHIRLWIND, TAIL_WHIP, LEER, GROWL, ROAR, SING, SUPERSONIC, DISABLE
 db LEECH_SEED, POISONPOWDER, STUN_SPORE, SLEEP_POWDER, THUNDER_WAVE, TOXIC
 db HYPNOSIS, SCREECH, SMOKESCREEN, CONFUSE_RAY, KINESIS, SPLASH, GLARE, POISON_GAS
 db LOVELY_KISS, SPORE, WILL_O_WISP, FLASH_FREEZE, CURSE, CHARM, $ff
