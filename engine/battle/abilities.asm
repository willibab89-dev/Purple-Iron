SECTION "Starter ability prototype", ROMX, BANK[$3a]

; Persistent ability slots share the versioned nature record. Legacy F9..FD
; tags are migrated by NatureEnsureMon without rerolling the ability slot.
AbilityFamily:
 ld [wAbilityResolvedExtended], a
 callab AbilityFamilyBanked
 ld a, [wAbilityResolvedExtended]
 ret

; C = one-based pool number, B = saved slot (1..5).
; A 16-bit offset allows more than 255 pool entries without changing saves.
AbilityResolvePoolId:
 push bc
 xor a
 ld [wAbilityResolvedExtended], a
 ld a, c
 dec a
 ld l, a
 ld h, 0
 ld d, h
 ld e, l
 add hl, hl
 add hl, hl
 add hl, de
 ld a, b
 dec a
 ld e, a
 ld d, 0
 add hl, de
 ld de, AbilityPoolIds
 add hl, de
 ld a, [wBuffer]
 push af
 ld de, wAbilityResolvedExtended
 ld bc, 1
 ld a, BANK(AbilityPoolIds)
 call FarCopyData
 ld a, [wAbilityResolvedExtended]
 ld d, a
 pop af
 ld [wBuffer], a
 xor a
 ld [wAbilityResolvedExtended], a
 ld a, d
 pop bc
 cp ABILITY_EXTENDED
 ret nz
 ; Each entry is pool, one-based slot, extended index (ID minus 255).
 ld hl, AbilityExtendedPoolIds
.find
 ld a, [hli]
 and a
 jr z, .missing
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
 ld a, ABILITY_EXTENDED
 ret
.missing
 xor a
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
 db 0

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
	jp AbilityResolvePoolId
.none
	ld b, 0
	ret

AbilityResetBattle:
	xor a
	ld [wActiveAbilityExtended], a
	ld [wActiveAbilityExtended + 1], a
	ld [wAbilityResolvedExtended], a
	ld [wParentalState], a
	ld [wStatAbilityGuard], a
	ld [wRolloutStacks], a
	ld [wRolloutStacks + 1], a
	ld [wPatientActed], a
	ld [wDeepSleepPending], a
	ld [wDeepSleepPending + 1], a
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
	jpab AbilityResourcefulNewMon

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
	ld [wAbilityResolvedExtended], a
.store
	ld [wActiveAbilities], a
	cp ABILITY_EXTENDED
	ld a, 0
	jr nz, .storeExtended
	ld a, [wAbilityResolvedExtended]
.storeExtended
	ld [wActiveAbilityExtended], a
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
	xor a
	ld [wAbilityResolvedExtended], a
	ld a, [wEnemyMonSpecies2]
	call AbilityFamily
	and a
	jr z, .store
	ld c, a
	ld a, [wNatureEnemySlot]
	ld b, a
	call AbilityResolvePoolId
.store
	ld [wActiveAbilities + 1], a
	cp ABILITY_EXTENDED
	ld a, 0
	jr nz, .storeExtended
	ld a, [wAbilityResolvedExtended]
.storeExtended
	ld [wActiveAbilityExtended + 1], a
	ld a, 1
	ld [wAbilitySide], a
	call AbilityEntry
	ld a, [wNatureIDs + 1]
	ld [wAbilityTemp], a
	ret

; Neutralizing Gas suppresses the opposing active ability while its holder lives.
; Preserve the returned pointer and BC/DE, as callers rely on them.
AbilityGet:
 push bc
 push de
 and a
 ld b, a
 ld hl, wActiveAbilities
 jr z, .read
 inc hl
.read
 ld a, [hl]
 cp AB_NEUTRALIZING_GAS
 jr z, .done
 ld c, a
 push hl
 ld a, b
 xor 1
 ld hl, wActiveAbilities
 ld de, wBattleMonHP
 and a
 jr z, .check
 inc hl
 ld de, wEnemyMonHP
.check
 ld a, [hl]
 cp AB_NEUTRALIZING_GAS
 jr nz, .unsuppressed
 ld a, [de]
 and a
 jr nz, .suppress
 inc de
 ld a, [de]
 and a
 jr z, .unsuppressed
.suppress
 ld c, 0
.unsuppressed
 pop hl
 ld a, c
.done
 cp ABILITY_EXTENDED
 jr nz, .clearExtended
 push hl
 ld hl, wActiveAbilityExtended
 push af
 ld a, b
 and a
 jr z, .readExtended
 inc hl
.readExtended
 ld a, [hl]
 ld [wAbilityResolvedExtended], a
 pop af
 pop hl
 jr .return
.clearExtended
 push af
 xor a
 ld [wAbilityResolvedExtended], a
 pop af
.return
 pop de
 pop bc
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
	xor a
	call AbilityGet
	ld [wAbilityCheckResult], a
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
	cp AB_LIMBER
	jr z, .limber
	cp AB_COLOSSAL_SIZE
	jr nz, .chlorophyll
	; Transform replaces saved, already-scaled stats with copied stats.
	ld hl, wPlayerBattleStatus3
	ld a, [wAbilitySide]
	and a
	jr z, .transformCheck
	ld hl, wEnemyBattleStatus3
.transformCheck
	bit TRANSFORMED, [hl]
	jr z, .plain
	pop hl
	ld b, h
	ld c, l
	srl h
	rr l
	srl h
	rr l
	push hl
	add hl, hl
	pop de
	add hl, de
	ld a, c
	and 3
	cp 2
	jr c, .minimum
	dec a
	ld e, a
	ld d, 0
	add hl, de
.minimum
	ld a, h
	or l
	ret nz
	inc l
	ret
.limber
	ld hl, wPlayerBattleStatus3
	ld a, [wAbilitySide]
	and a
	jr z, .limberTransform
	ld hl, wEnemyBattleStatus3
.limberTransform
	bit TRANSFORMED, [hl]
	jr z, .plain
	pop hl
	ld a, h
	ld [H_QUOTIENT + 2], a
	ld a, l
	ld [H_QUOTIENT + 3], a
	ld c, 120
	call AbilityScaleAccuracy
	ld a, [H_QUOTIENT + 2]
	ld h, a
	ld a, [H_QUOTIENT + 3]
	ld l, a
	ret
.chlorophyll
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
	ld [wParentalState], a
	ld [wMoveMissed], a
	call AbilityEarlyBirdBeforeAction
	call AbilityTargetStatus
	ld a, [hl]
	ld [wAbilityOldStatus], a
	call AbilityInfiltratorStart
	call AbilitySteadfastActor
	call AbilityMindGamesBefore
	call AbilityDeepSleepClearAwake
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
	call AbilityParentalAfterHit
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
	abilitycall AbilitySleepAfterAction
	abilitycall AbilityMindGamesAfter
	abilitycall AbilityPatientMarkAction
	abilitycall AbilityInfiltratorRestore
	abilitycall AbilityElusiveAfterAttack
	abilitycall AbilityLowHPBoth ; recoil can cross a threshold mid-turn
	abilitycall AbilityFrenzy
	abilitycall AbilityShortTemper
	abilitycall AbilitySandAfterAction
	abilitycall AbilityRolloutAfterAction
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
	call AbilityNightmareBoth
	call AbilityGasLeakBoth
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
	cp AB_GRIMER_TOXIC_WASTE
	jp z, AbilityGrimerToxicWaste
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
; Description data lives in the expanded ability bank.
AbilityDrawDescription:
	ld [wAbilityTemp], a
	jpab AbilityDrawDescriptionBanked

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

INCLUDE "engine/battle/expanded_abilities.asm"
