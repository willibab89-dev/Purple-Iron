SECTION "Starter ability prototype", ROMX, BANK[$3a]

; Persistent ability slots share the versioned nature record. Legacy F9..FD
; tags are migrated by NatureEnsureMon without rerolling the ability slot.
AbilityFamily:
	ld b, a
	ld hl, AbilitySpeciesPools
.loop
	ld a, [hli]
	and a
	ret z
	cp b
	ld a, [hli]
	ret z
	jr .loop

AbilitySpeciesPools:
	db BULBASAUR, 1
	db IVYSAUR, 1
	db VENUSAUR, 1
	db CHARMANDER, 6
	db CHARMELEON, 6
	db CHARIZARD, 6
	db SQUIRTLE, 11
	db WARTORTLE, 11
	db BLASTOISE, 11
	db CATERPIE, 16
	db METAPOD, 21
	db BUTTERFREE, 26
	db WEEDLE, 31
	db KAKUNA, 36
	db BEEDRILL, 41
	db PIDGEY, 46
	db PIDGEOTTO, 46
	db PIDGEOT, 46
	db RATTATA, 51
	db RATICATE, 51
	db SPEAROW, 56
	db FEAROW, 56
	db EKANS, 61
	db ARBOK, 61
	db PIKACHU, 66
	db RAICHU, 66
	db SANDSHREW, 71
	db SANDSLASH, 76
	db NIDORAN_F, 81
	db NIDORINA, 81
	db NIDOQUEEN, 81
	db NIDORAN_M, 86
	db NIDORINO, 86
	db NIDOKING, 86
	db CLEFAIRY, 91
	db CLEFABLE, 91
	db VULPIX, 96
	db NINETALES, 96
	db JIGGLYPUFF, 101
	db WIGGLYTUFF, 101
	db ZUBAT, 106
	db GOLBAT, 106
	db CROBAT, 106
	db ODDISH, 111
	db GLOOM, 116
	db VILEPLUME, 111
	db PARAS, 121
	db PARASECT, 126
	db VENONAT, 131
	db VENOMOTH, 131
	db DIGLETT, 136
	db DUGTRIO, 136
	db MEOWTH, 141
	db PERSIAN, 141
	db PSYDUCK, 146
	db GOLDUCK, 151
	db MANKEY, 156
	db PRIMEAPE, 156
	db GROWLITHE, 161
	db ARCANINE, 166
	db POLIWAG, 171
	db POLIWHIRL, 171
	db POLIWRATH, 176
	db 0
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

; A = one-based pool offset plus zero-based slot.
AbilityResolvePoolId:
	dec a
	ld e, a
	ld d, 0
	ld hl, AbilityPoolIds
	add hl, de
	ld a, [hl]
	ret

; Nature format keeps the persistent ability slot in stored Type1 high bits.
AbilityEnsureMon:
	naturecall NatureEnsureMon
	ld a, [hl]
	call AbilityFamily
	and a
	jr z, .none
	ld c, a
	ld a, [wNatureSlot]
	ld b, a
	dec a
	add c
	jp AbilityResolvePoolId
.none
	ld b, 0
	ret

AbilityResetBattle:
	xor a
	ld [wAbilityHit], a
	ld [wAbilityPPLeft], a
	ld [wAbilityCheckResult], a
	ld [wNatureMode], a
	ld hl, wAbilityFlags
	ld b, 14
	xor a
.loop
	ld [hli], a
	dec b
	jr nz, .loop
	ret

AbilityAssignNewMon:
	; NatureInitializeNewMon has already assigned the saved slot.
	jp AbilityResourcefulNewMon

AbilityLoadPlayer:
	push af
	push bc
	push de
	push hl
	ld a, [wLinkState]
	cp LINK_STATE_BATTLING
	jr z, .disabled
	ld a, [wWhichPokemon]
	ld hl, wPartyMon1
	ld bc, wPartyMon2 - wPartyMon1
	call AddNTimes
	call AbilityEnsureMon
	push af
	ld a, [wNatureID]
	ld [wNatureIDs], a
	ld [wNatureStatSources], a
	ld a, [wNatureMode]
	or 1
	ld [wNatureMode], a
	pop af
	jr .store
.disabled
	xor a
.store
	ld [wActiveAbilities], a
	xor a
	ld [wAbilitySide], a
	call AbilityPlayerEntry
	pop hl
	pop de
	pop bc
	pop af
	ret

; Nature initialization has already cached the stable enemy slot.
AbilityLoadEnemy:
	ld a, [wEnemyMonSpecies2]
	call AbilityFamily
	and a
	jr z, .store
	ld c, a
	ld a, [wNatureEnemySlot]
	dec a
	add c
	call AbilityResolvePoolId
.store
	ld [wActiveAbilities + 1], a
	ld a, 1
	ld [wAbilitySide], a
	call AbilityEntry
	ld a, [wNatureIDs + 1]
	ld [wAbilityTemp], a
	ret

AbilityGet:
	ld hl, wActiveAbilities
	and a
	jr z, .read
	inc hl
.read
	ld a, [hl]
	ret

AbilityActor:
	ld a, [H_WHOSETURN]
	jp AbilityGet

; wAbilitySide is an absolute side, independent of whose action is executing.
AbilityHP:
	ld hl, wBattleMonHP
	ld de, wBattleMonMaxHP
	ld a, [wAbilitySide]
	and a
	ret z
	ld hl, wEnemyMonHP
	ld de, wEnemyMonMaxHP
	ret

; Carry iff living current HP is strictly less than one third maximum HP.
AbilityBelowThird:
	call AbilityHP
	ld a, [hli]
	ld l, [hl]
	ld h, a
	ld a, h
	or l
	jr z, .no
	ld b, h
	ld c, l
	add hl, hl
	jr c, .no
	add hl, bc
	jr c, .no
	ld a, [de]
	ld b, a
	inc de
	ld a, [de]
	ld c, a
	ld a, h
	cp b
	ret c
	jr nz, .no
	ld a, l
	cp c
	ret
.no
	and a
	ret

AbilityDamageBoost:
	push af
	push bc
	push de
	push hl
	call AbilityModifyDamage
	pop hl
	pop de
	pop bc
	pop af
	ret

AbilityPrepareSpeeds:
	abilitycall AbilityLowHPBoth
	abilitycall AbilityQuickFeetBoth
	call AbilitySteadfastActor
	push af
	push bc
	push de
	push hl
	xor a
	ld [wAbilitySide], a
	call AbilityOneSpeed
	ld a, h
	ld [wAbilityPlayerSpeed], a
	ld a, l
	ld [wAbilityPlayerSpeed + 1], a
	ld a, 1
	ld [wAbilitySide], a
	call AbilityOneSpeed
	ld a, h
	ld [wAbilityEnemySpeed], a
	ld a, l
	ld [wAbilityEnemySpeed + 1], a
	pop hl
	pop de
	pop bc
	pop af
	ret

AbilityOneSpeed:
	ld hl, wBattleMonSpeed
	ld a, [wAbilitySide]
	and a
	jr z, .read
	ld hl, wEnemyMonSpeed
.read
	ld a, [hli]
	ld l, [hl]
	ld h, a
	push hl
	ld a, [wAbilitySide]
	call AbilityGet
	cp 2
	jr nz, .plain
	call AbilityBelowThird
	jr nc, .plain
	pop hl
	ld b, h
	ld c, l
	srl b
	rr c
	add hl, bc
	ret nc
	ld hl, $ffff
	ret
.plain
	pop hl
	ret

AbilityTargetStatus:
	ld hl, wEnemyMonStatus
	ld a, [H_WHOSETURN]
	and a
	ret z
	ld hl, wBattleMonStatus
	ret

AbilityBeforeAction:
	push af
	push bc
	push de
	push hl
	xor a
	ld [wAbilityHit], a
	ld [wMoveMissed], a
	call AbilityTargetStatus
	ld a, [hl]
	ld [wAbilityOldStatus], a
	call AbilityInfiltratorStart
	call AbilitySteadfastActor
	call AbilityCachePP
	pop hl
	pop de
	pop bc
	pop af
	ret

AbilityAfterHit:
	push af
	push bc
	push de
	push hl
	call AbilityHitEvents
	pop hl
	pop de
	pop bc
	pop af
	ret

AbilityActorMoveType:
	ld hl, wPlayerMoveType
	ld a, [H_WHOSETURN]
	and a
	jr z, .read
	ld hl, wEnemyMoveType
.read
	ld a, [hl]
	ret

AbilityFlagsPointer:
	ld hl, wAbilityFlags
	ld a, [wAbilitySide]
	and a
	ld a, [wPlayerMonNumber]
	jr z, .index
	ld hl, wAbilityFlags + 6
	ld a, [wIsInBattle]
	cp 2
	jr z, .trainerIndex
	xor a ; wild enemies have no party position
	jr .index
.trainerIndex
	ld a, [wEnemyMonPartyPos]
	cp 6
	jr c, .index
	xor a ; guard against the pre-send-out sentinel
.index
	ld c, a
	ld b, 0
	add hl, bc
	ret

AbilityRaiseStage:
	ld [wCustomStat], a
	ld a, [wAbilitySide]
	ld [wCustomSide], a
	ld a, 1
	ld [wCustomDelta], a
	xor a
	ld [wCustomChanged], a
	jpab CustomChangeStage

AbilityAfterAction:
	abilitycall AbilityInfiltratorRestore
	abilitycall AbilityElusiveAfterAttack
	abilitycall AbilityLowHPBoth ; recoil can cross a threshold mid-turn
	abilitycall AbilityFrenzy
	abilitycall AbilityShortTemper
	abilitycall AbilitySandAfterAction
	abilitycall AbilityFoxfire
	abilitycall AbilitySoothingVoice
	abilitycall AbilityQuickFeetBoth
	push af
	push bc
	push de
	push hl
	ld a, [H_WHOSETURN]
	ld [wAbilitySide], a
	call AbilityHP
	ld a, [hli]
	or [hl]
	jp z, .done
	call AbilityActor
	cp 8
	jr nz, .confident
	ld a, [wAbilityOldStatus]
	and a
	jr nz, .done
	call AbilityTargetStatus
	bit BRN, [hl]
	jr z, .done
	ld a, [H_WHOSETURN]
	ld [wAbilitySide], a
	xor a ; Attack
	call AbilityRaiseStage
	jr .done
.confident
	cp 10
	jr nz, .done
	ld a, [wMoveMissed]
	and a
	jr z, .done
	ld a, [wDamageMultipliers]
	and $7f
	jr z, .done ; an immunity is not an accuracy miss
	ld hl, wPlayerMovePower
	ld a, [H_WHOSETURN]
	ld [wAbilitySide], a
	and a
	jr z, .power
	ld hl, wEnemyMovePower
.power
	ld a, [hl]
	and a
	jr z, .done
	call AbilityFlagsPointer
	bit 1, [hl]
	jr nz, .done
	set 1, [hl]
	ld a, 4 ; Accuracy
	call AbilityRaiseStage
.done
	pop hl
	pop de
	pop bc
	pop af
	ret

AbilityEndRound:
	call AbilityLowHPBoth
	ld a, [wResidualRoundDone]
	and a
	ret nz
	xor a
	ld [wAbilitySide], a
	call AbilityPhotosynthesis
	ld a, 1
	ld [wAbilitySide], a
	call AbilityPhotosynthesis
	xor a
	ld [wAbilitySide], a
	call AbilityShedSkin
	ld a, 1
	ld [wAbilitySide], a
	call AbilityShedSkin
	jp AbilityQuickFeetBoth
AbilityPhotosynthesis:
	ld a, [wAbilitySide]
	call AbilityGet
	cp AB_REGENERATION
	jp z, AbilityRegeneration
	cp AB_TOXIC_WASTE
	jr z, .poisonRecovery
	cp AB_POISON_ABSORB
	jr nz, .notToxicWaste
.poisonRecovery
	jp AbilityToxicWaste
.notToxicWaste
	cp AB_MOON_CHILD
	jr z, .unconditionalHeal
	cp AB_REGROWTH
	jr nz, .notMoon
.unconditionalHeal
	call AbilityHP
	ld a, [hli]
	or [hl]
	ret z
	dec hl
	ld a, 4
	jp AbilityHealFractionFromHL
.notMoon
	cp 4
	ret nz
	call AbilityHP
	push hl
	ld a, [hli]
	ld l, [hl]
	ld h, a
	add hl, hl
	ld a, [de]
	ld b, a
	inc de
	ld a, [de]
	ld c, a
	dec de
	ld a, h
	cp b
	jr c, AbilityPhotosynthesisNoHeal
	jr nz, .notEqual
	ld a, l
	cp c
	jr c, AbilityPhotosynthesisNoHeal
	jr z, AbilityPhotosynthesisNoHeal
.notEqual
	pop hl
	ld a, 4 ; 1/16
	jr AbilityHealFractionFromHL

; A = shift count, HL = living holder HP, DE = holder max HP.
AbilityHealFractionFromHL:
	ld [wAbilityTemp + 1], a
	push hl
	ld a, [de]
	ld h, a
	inc de
	ld a, [de]
	ld l, a
	ld b, h
	ld c, l
.shift
	srl b
	rr c
	ld a, [wAbilityTemp + 1]
	dec a
	ld [wAbilityTemp + 1], a
	jr nz, .shift
	ld a, b
	or c
	jr nz, .amount
	inc c
.amount
	pop hl
	push hl
	ld a, [hli]
	ld l, [hl]
	ld h, a
	add hl, bc
	ld a, [de]
	ld c, a
	dec de
	ld a, [de]
	ld b, a
	ld a, h
	cp b
	jr c, .store
	jr nz, .cap
	ld a, l
	cp c
	jr c, .store
.cap
	ld h, b
	ld l, c
.store
	ld b, h
	ld c, l
	pop hl
	ld [hl], b
	inc hl
	ld [hl], c
	ld a, [wAbilitySide]
	ld [wCustomSide], a
	jpab UtilitySyncParty
AbilityPhotosynthesisNoHeal:
	pop hl
	ret

AbilityPoisonedText:
	TX_FAR _PoisonedText
	db "@"
AbilityBurnedText:
	TX_FAR _BurnedText
	db "@"

; Battle inspection: SELECT opens, left/right switches side, B/SELECT closes.
AbilityPanel:
	call SaveScreenTilesToBuffer2
	xor a
	ld [wAbilityPanelSide], a
.draw
	call ClearScreen
	coord hl, 0, 0
	lb bc, 16, 18
	call TextBoxBorder
	coord hl, 2, 2
	ld de, AbilityPlayerLabel
	ld a, [wAbilityPanelSide]
	and a
	jr z, .label
	ld de, AbilityEnemyLabel
.label
	call PlaceString
	ld a, [wAbilityPanelSide]
	call AbilityGet
	call AbilityDrawDescription
	coord hl, 2, 14
	ld de, AbilityPanelHelp
	call PlaceString
.wait
	call DelayFrame
	call JoypadLowSensitivity
	ld a, [hJoy5]
	and B_BUTTON | SELECT
	jr nz, .close
	ld a, [hJoy5]
	and D_LEFT | D_RIGHT
	jr z, .wait
	ld a, [wAbilityPanelSide]
	xor 1
	ld [wAbilityPanelSide], a
	jr .draw
.close
	call LoadScreenTilesFromBuffer2
	ret
AbilityPlayerLabel:
	db "YOUR ABILITY@"
AbilityEnemyLabel:
	db "FOE'S ABILITY@"
AbilityPanelHelp:
	db "LEFT/RIGHT SIDE",$4e,"B/SELECT CLOSE@"
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

; Shared renderer: A = ability ID. Does not change either active battle ID.
AbilityDrawDescription:
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
	call PlaceString
	ret

; Invoked from the overworld party action menu. Buffer 2 contains the saved
; overworld screen, so only buffer 1 may be used here.
PartyAbilityPanel:
	call ClearSprites
	call SaveScreenTilesToBuffer1
	ld a, [wWhichPokemon]
	ld hl, wPartyMon1
	ld bc, wPartyMon2 - wPartyMon1
	call AddNTimes
	call AbilityEnsureMon
	ld [wAbilityID], a
	call ClearScreen
	coord hl, 0, 0
	lb bc, 16, 18
	call TextBoxBorder
	ld hl, wPartyMonNicks
	ld a, [wWhichPokemon]
	call SkipFixedLengthTextEntries
	ld d, h
	ld e, l
	coord hl, 2, 2
	call PlaceString
	ld a, [wAbilityID]
	call AbilityDrawDescription
	coord hl, 2, 14
	ld de, PartyAbilityHelp
	call PlaceString
.wait
	call DelayFrame
	call JoypadLowSensitivity
	ld a, [hJoy5]
	and A_BUTTON | B_BUTTON | SELECT
	jr z, .wait
	jp LoadScreenTilesFromBuffer1
PartyAbilityHelp:
	db "A/B CLOSE@"

; Do not initialize or alter an unsupported species when using a capsule.
AbilityCapsuleCheck::
	ld a, [wNatureMonPtr]
	ld h, a
	ld a, [wNatureMonPtr + 1]
	ld l, a
	ld a, [hl]
	call AbilityFamily
	ld [wAbilityID], a
	ret

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

INCLUDE "engine/battle/expanded_abilities.asm"

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
