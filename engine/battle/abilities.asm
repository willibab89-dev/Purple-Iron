SECTION "Starter ability prototype", ROMX, BANK[$3a]

; Persistent ability slots share the versioned nature record. Legacy F9..FD
; tags are migrated by NatureEnsureMon without rerolling the ability slot.
AbilityFamily:
	cp BULBASAUR
	jr z, .grass
	cp IVYSAUR
	jr z, .grass
	cp VENUSAUR
	jr z, .grass
	cp CHARMANDER
	jr z, .fire
	cp CHARMELEON
	jr z, .fire
	cp CHARIZARD
	jr z, .fire
	xor a
	ret
.grass
	ld a, 1
	ret
.fire
	ld a, 6
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
	ret
.none
	ld b, 0
	ret

AbilityResetBattle:
	xor a
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
.store
	ld [wActiveAbilities + 1], a
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
	ld a, [wUnusedC000]
	bit 4, a
	jr nz, .done
	call AbilityActor
	ld [wAbilityID], a
	ld a, [H_WHOSETURN]
	ld [wAbilitySide], a
	ld hl, wPlayerMovePower
	and a
	jr z, .move
	ld hl, wEnemyMovePower
.move
	ld a, [hli]
	and a
	jr z, .done
	ld a, [hl]
	ld b, a
	ld a, [wAbilityID]
	cp 5 ; Thick Vines: every physical move, not just contact/Grass.
	jr nz, .overgrowth
	ld a, b
	cp FIRE
	jr nc, .done
	ld c, 120
	jr .multiply
.overgrowth
	cp 3
	jr nz, .blaze
	ld a, b
	cp GRASS
	jr nz, .done
	call AbilityHP
	ld a, [de]
	cp [hl]
	jr nz, .done
	inc de
	inc hl
	ld a, [de]
	cp [hl]
	jr nz, .done
	jr .quarter
.blaze
	cp 6
	jr nz, .done
	ld a, b
	cp FIRE
	jr nz, .done
	call AbilityBelowThird
	jr nc, .done
.quarter
	ld c, 125
.multiply
	xor a
	ld [H_MULTIPLICAND], a
	ld a, [wDamage]
	ld [H_MULTIPLICAND + 1], a
	ld a, [wDamage + 1]
	ld [H_MULTIPLICAND + 2], a
	ld a, c
	ld [H_MULTIPLIER], a
	call Multiply
	ld a, 100
	ld [H_DIVISOR], a
	ld b, 4
	call Divide
	ld a, [H_QUOTIENT + 2]
	ld [wDamage], a
	ld a, [H_QUOTIENT + 3]
	ld [wDamage + 1], a
.done
	pop hl
	pop de
	pop bc
	pop af
	ret

AbilityPrepareSpeeds:
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
	ld hl, wPlayerMovePower
	ld a, [H_WHOSETURN]
	and a
	jr z, .power
	ld hl, wEnemyMovePower
.power
	ld a, [hl]
	and a
	jp z, .done
	ld a, [wCustomTargetHadSub]
	and a
	jp nz, .done
	ld a, [wDamage]
	ld b, a
	ld a, [wDamage + 1]
	or b
	jp z, .done
	call AbilityTargetStatus
	dec hl
	ld a, [hld]
	or [hl]
	jp z, .done ; no effects on a fainted target
	ld a, 1
	ld [wAbilityHit], a
	ld a, [H_WHOSETURN]
	ld [wAbilitySide], a
	call AbilityActorMoveType
	ld [wAbilityMoveType], a
	; Hot Temper is once for this party member, including multi-hits/switches.
	cp FIRE
	jr nc, .attacker
	ld a, [H_WHOSETURN]
	xor 1
	call AbilityGet
	cp 9
	jr nz, .attacker
	ld a, [H_WHOSETURN]
	xor 1
	ld [wAbilitySide], a
	call AbilityFlagsPointer
	bit 0, [hl]
	jr nz, .attacker
	set 0, [hl]
	ld a, 3 ; Special
	call AbilityRaiseStage
.attacker
	call AbilityActor
	cp 1
	jr nz, .combustion
	ld a, [wAbilityMoveType]
	cp GRASS
	jp nz, .done
	ld b, 64 ; 25%
	ld c, 1 << PSN
	jr .status
.combustion
	cp 7
	jp nz, .done
	ld a, [wAbilityMoveType]
	cp FIRE
	jp z, .done
	ld b, 38 ; 14.84%, nearest 8-bit threshold
	ld c, 1 << BRN
.status
	call AbilityTargetStatus
	ld a, [hl]
	and a
	jp nz, .done
	inc hl
	ld a, c
	cp 1 << PSN
	ld a, POISON
	jr z, .immuneType
	ld a, FIRE
.immuneType
	cp [hl]
	jp z, .done
	inc hl
	cp [hl]
	jp z, .done
	push bc
	callab CustomRandomInBattleBank
	ld a, [wCustomRandomValue]
	pop bc
	cp b
	jp nc, .done
	call AbilityTargetStatus
	ld [hl], c
	ld a, [H_WHOSETURN]
	xor 1
	ld [wCustomSide], a
	ld a, c
	cp 1 << PSN
	jr nz, .burn
	; Poison cannot coexist with this game's Curse.
	callab ResidualState
	bit 1, [hl]
	jr z, .poison
	call AbilityTargetStatus
	ld [hl], 0
	jp .done
.poison
	callab CustomRecalculate
	ld hl, AbilityPoisonedText
	jr .sync
.burn
	callab CustomRecalculate
	ld hl, AbilityBurnedText
.sync
	push hl
	callab UtilitySyncParty
	pop hl
	call PrintText
.done
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
	dw AbilityNone, AbilityPoisonLeaf, AbilityChlorophyll, AbilityOvergrowth, AbilityPhotosynthesisText, AbilityThickVines
	dw AbilityBlaze, AbilityCombustion, AbilityWildfire, AbilityHotTemper, AbilityConfident
AbilityNone:
	db "NO ABILITY",$4e,"Prototype",$4e,"Starter lines.@"
AbilityPoisonLeaf:
	db "POISON LEAF",$4e,"Grass hits have a",$4e,"25% poison odds.@"
AbilityChlorophyll:
	db "CHLOROPHYLL",$4e,"Speed x1.5 while",$4e,"HP is below 1/3.@"
AbilityOvergrowth:
	db "OVERGROWTH",$4e,"Grass power x1.25",$4e,"at full HP.@"
AbilityPhotosynthesisText:
	db "PHOTOSYNTHESIS",$4e,"Heal 1/16 HP each",$4e,"turn above 1/2.@"
AbilityThickVines:
	db "THICK VINES",$4e,"Physical damage",$4e,"multiplied x1.2.@"
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
