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
	ret ; NatureInitializeNewMon assigns the shared record before stat generation.

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
	ld a, [wEnemyMonPartyPos]
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
	abilitycall AbilityFrenzy
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
AbilityPhotosynthesis:
	ld a, [wAbilitySide]
	call AbilityGet
	cp AB_REGENERATION
	jp z, AbilityRegeneration
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
	jr c, .noHeal
	jr nz, .notEqual
	ld a, l
	cp c
	jr c, .noHeal
	jr z, .noHeal
.notEqual
	pop hl
	push hl
	ld a, [de]
	ld h, a
	inc de
	ld a, [de]
	ld l, a
	ld b, h
	ld c, l
	rept 4
	srl b
	rr c
	endr
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
.noHeal
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
	add a
	ld c, a
	ld b, 0
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

INCLUDE "engine/battle/expanded_abilities.asm"
