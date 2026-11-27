SECTION "Expanded ability descriptions", ROMX, BANK[$39]

; Extended IDs from 322 onward use this separate bank.
AbilityDrawExtraDescription:
 ld a, [wAbilityResolvedExtended]
 sub AB_CONSERVATIVE - ABILITY_EXTENDED
 cp 52
 jr nc, .none
 ld c, a
 ld b, 0
 sla c
 rl b
 ld hl, AbilityExtraTextPointers
 add hl, bc
 ld a, [hli]
 ld d, [hl]
 ld e, a
 coord hl, 2, 4
 jp PlaceString
.none
 ld de, AbilityExtraNone
 coord hl, 2, 4
 jp PlaceString

AbilityExtraTextPointers:
	dw AbilityText322, AbilityText323, AbilityText324, AbilityText325
	dw AbilityText326, AbilityText327, AbilityText328, AbilityText329
	dw AbilityText330, AbilityText331, AbilityText332, AbilityText333
	dw AbilityText334, AbilityText335, AbilityText336, AbilityText337
	dw AbilityText338, AbilityText339, AbilityText340, AbilityText341
	dw AbilityText342, AbilityText343, AbilityText344, AbilityText345
	dw AbilityText346, AbilityText347, AbilityText348, AbilityText349
	dw AbilityText350, AbilityText351, AbilityText352, AbilityText353
	dw AbilityText354, AbilityText355, AbilityText356, AbilityText357
	dw AbilityText358, AbilityText359, AbilityText360, AbilityText361
	dw AbilityText362, AbilityText363, AbilityText364, AbilityText365
	dw AbilityText366, AbilityText367, AbilityText368, AbilityText369
	dw AbilityText370, AbilityText371, AbilityText372, AbilityText373
AbilityExtraNone: db "NO ABILITY@"
AbilityText322: db "CONSERVATIVE",$4e,"Moves: 25% chance",$4e,"to save PP.@"
AbilityText323: db "TRACE",$4e,"Copies foe ability",$4e,"until switch out.@"
AbilityText324: db "ANTIVIRUS",$4e,"Immune to major",$4e,"status conditions.@"
AbilityText325: db "OVERCLOCK",$4e,"Normal move: Speed",$4e,"+1 once per battle.@"
AbilityText326: db "DOWNLOAD",$4e,"Entry: Attack or",$4e,"Special +1.@"
AbilityText327: db "ANCIENT POWER",$4e,"Hits: 10% all stats",$4e,"+1 once per battle.@"
AbilityText328: db "MIND'S EYE",$4e,"Ignores foe evasion;",$4e,"hits Ghosts.@"
AbilityText329: db "EXECUTIONER",$4e,"Physical x1.2 vs",$4e,"foes below half HP.@"
AbilityText330: db "TERRIFYING",$4e,"Entry: foe Defense",$4e,"-1 once per battle.@"
AbilityText331: db "HEAVY SLEEPER",$4e,"Asleep: heal 1/16",$4e,"HP each turn.@"
AbilityText332: db "SLEEPWALKER",$4e,"Acts asleep; deals",$4e,"half damage.@"
AbilityText333: db "ABSOLUTE ZERO",$4e,"Ice attacks ignore",$4e,"Ice resistance.@"
AbilityText334: db "LIGHTNING SPEED",$4e,"Electric moves",$4e,"gain priority +1.@"
AbilityText335: db "INTENSE FLAMES",$4e,"Damaging hits burn",$4e,"the target.@"
AbilityText336: db "MYSTIC SCALES",$4e,"Special damage",$4e,"received x0.8.@"
AbilityText337: db "SERPENT GRACE",$4e,"Dragon move: Evasion",$4e,"+1 once per battle.@"
AbilityText338: db "MARVEL SCALE",$4e,"Status: Defense +1",$4e,"until cured.@"
AbilityText339: db "MULTISCALE",$4e,"At full HP:",$4e,"damage x0.5.@"
AbilityText340: db "INNER FOCUS",$4e,"Prevents flinching",$4e,"and confusion.@"
AbilityText341: db "DOMINANCE",$4e,"Foe cannot lower",$4e,"stats or add status.@"
AbilityText342: db "ANCESTOR",$4e,"All move types get",$4e,"same-type bonus.@"
AbilityText343: db "MERCILESS",$4e,"Critical hits vs",$4e,"poisoned targets.@"
AbilityText344: db "BARBED SHELL",$4e,"Contact hurts foe",$4e,"for 1/8 max HP.@"
AbilityText345: db "TRICKSTER",$4e,"Damage x1.25 vs",$4e,"confused foes.@"
AbilityText346: db "SHADOW AMBUSH",$4e,"Ghost x1.3 vs foe",$4e,"at full HP.@"
AbilityText347: db "CLAY ARMOR",$4e,"Water damage x0.5;",$4e,"Water hit: Atk +2.@"
AbilityText348: db "TECTONIC WRATH",$4e,"Ground damage x1.5.@"
AbilityText349: db "POISON POINT",$4e,"Contact: 20% chance",$4e,"to poison foe.@"
AbilityText350: db "SHADOW BOXING",$4e,"Punch: Evasion or",$4e,"Speed +1 at random.@"
AbilityText351: db "GIGANTISM",$4e,"Maximum HP x2.@"
AbilityText352: db "TERRIFYING",$4e,"Entry: foe Defense",$4e,"-1.@"
AbilityText353: db "SPIKED SHELL",$4e,"Contact hurts foe",$4e,"for 1/16 max HP.@"
AbilityText354: db "INDOMITABLE",$4e,"First super hit:",$4e,"damage x0.5.@"
AbilityText355: db "SINISTER",$4e,"Physical x1.25 vs",$4e,"poisoned foes.@"
AbilityText356: db "RECOVERY",$4e,"Heal 1/8 HP while",$4e,"foe is poisoned.@"
AbilityText357: db "SHARP VINES",$4e,"Critical chance",$4e,"+25 points.@"
AbilityText358: db "BIG BLOOM",$4e,"Grass move: heal",$4e,"1/8 maximum HP.@"
AbilityText359: db "DISCIPLINE",$4e,"Immune to status,",$4e,"confusion, flinch.@"

AbilityText360: db "HAPPY RETURN",$4e,"Transform: heal",$4e,"1/4 HP once.@"
AbilityText361: db "DUELIST",$4e,"Fighting hit: Def",$4e,"+1 once per battle.@"
AbilityText362: db "SHELL REFLEX",$4e,"Physical hit: Speed",$4e,"+1 once per battle.@"
AbilityText363: db "EFFICIENT",$4e,"Damage moves: 20%",$4e,"chance to save PP.@"
AbilityText364: db "KINDLING",$4e,"Normal move powers",$4e,"next Fire move.@"
AbilityText365: db "ANCIENT MALICE",$4e,"Hits: 10% chance",$4e,"to confuse foe.@"
AbilityText366: db "TOXIC PURSUIT",$4e,"Damage moves first",$4e,"vs poisoned foes.@"
AbilityText367: db "CAREGIVER",$4e,"Heal Bell heals team",$4e,"1/8 HP once.@"
AbilityText368: db "BORROWED STRENGTH",$4e,"Duplicate moves hit",$4e,"again for half.@"
AbilityText369: db "HORN SPECIALIST",$4e,"Horn moves: Fighting",$4e,"bonus; Normal chart.@"

AbilityText370: db "BEAR RAGE",$4e,"Half HP: Attack +1",$4e,"once per battle.@"
AbilityText371: db "FURNACE",$4e,"Physical hit:",$4e,"Special +1.@"
AbilityText372: db "FLAME BODY",$4e,"Contact: 20% burn",$4e,"the attacker.@"
AbilityText373: db "BLAZE",$4e,"Low HP: Fire moves",$4e,"deal x1.5 damage.@"
