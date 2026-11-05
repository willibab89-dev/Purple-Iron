SECTION "Utility move effects", ROMX, BANK[$34]

; Transient Counter record is reset independently of the old trapping damage.
ClearCounterRecord:
	xor a
	ld [wCounterDamage], a
	ld [wCounterDamage + 1], a
	dec a
	ld [wCounterRecipient], a
	ret

; Called only after the normal attack's HP application, before draining/recoil.
; Confusion, crash and residual damage never call this hook.
RecordCounterHit:
	ld a, [wCustomTargetHadSub]
	and a
	ret nz
	call CustomActorMove
	ld a, [hl]
	cp COUNTER
	ret z
	ld a, [H_WHOSETURN]
	xor 1
	ld [wCounterRecipient], a
	ld a, [de] ; effect pointer -> power -> type
	inc de
	inc de
	ld a, [de]
	cp FIRE
	jr c, .physical
	xor a
	ld [wCounterDamage], a
	ld [wCounterDamage + 1], a
	ret
.physical
	ld a, [wDamage]
	ld [wCounterDamage], a
	ld a, [wDamage + 1]
	ld [wCounterDamage + 1], a
	ret

UtilityCounter:
	call CustomActorMove
	ld a, [hl]
	cp COUNTER
	ret nz ; NZ means use the ordinary damage path
	xor a
	ld [wCriticalHitOrOHKO], a
	ld a, [H_WHOSETURN]
	ld b, a
	ld a, [wCounterRecipient]
	cp b
	jr nz, .failed
	ld hl, wEnemyMonType
	ld a, [H_WHOSETURN]
	and a
	jr z, .types
	ld hl, wBattleMonType
.types
	ld a, [hli]
	cp GHOST
	jr z, .failed
	ld a, [hl]
	cp GHOST
	jr z, .failed
	ld a, [wCounterDamage]
	ld b, a
	ld a, [wCounterDamage + 1]
	ld c, a
	or b
	jr z, .failed
	sla c
	rl b
	jr nc, .store
	ld bc, $ffff
.store
	ld a, b
	ld [wDamage], a
	ld a, c
	ld [wDamage + 1], a
	xor a
	ld [wMoveMissed], a
	callab MoveHitTest
	xor a ; Z means damage/miss was resolved by Counter
	ret
.failed
	xor a
	ld [wDamage], a
	ld [wDamage + 1], a
	inc a
	ld [wMoveMissed], a
	xor a
	ret

UtilityLoadMove:
	call CustomActorMove
	ld a, [hl]
	ld [wCustomMove], a
	ret

UtilityHitEffect:
	ld a, [wMoveMissed]
	and a
	ret nz
	ld a, [wCustomTargetHadSub]
	and a
	ret nz
	call CustomSetTarget
	call UtilityStatusPointer
	dec hl
	dec hl
	dec hl
	ld a, [hli]
	or [hl]
	ret z
	call UtilityLoadMove
	cp EGG_BOMB
	jp z, UtilityBreakScreens
	cp BRICK_BREAK
	jp z, UtilityBreakScreens
	cp MIND_BREAK
	jr z, .special
	cp GALE_WIND
	jr z, .evasion
	cp SCALD
	jr z, .scald
	cp POISON_FANG
	jr z, .fang
	; Tri Attack: one 51/256 gate, one uniform three-way draw, no reroll
	; when the selected ailment is blocked by typing or an existing status.
	call CustomRandom
	ld a, [wCustomRandomValue]
	cp 51
	ret nc
.triRoll
	call CustomRandom
	ld a, [wCustomRandomValue]
	cp 255
	jr z, .triRoll
.reduce
	cp 3
	jr c, .triChoice
	sub 3
	jr .reduce
.triChoice
	ld b, 1 << BRN
	and a
	jr z, .ailment
	ld b, 1 << FRZ
	dec a
	jr z, .ailment
	ld b, 1 << PAR
.ailment
	ld a, b
	ld [wCustomDelta], a
	jp UtilityInflictStatus
.scald
	call CustomRandom
	ld a, [wCustomRandomValue]
	cp 77
	ret nc
	ld a, 1 << BRN
	ld [wCustomDelta], a
	jp UtilityInflictStatus
.fang
	call CustomRandom
	ld a, [wCustomRandomValue]
	cp 51
	ret nc
	ld a, 1 << PSN
	ld [wCustomDelta], a
	jp UtilityInflictStatus
.special
	ld a, 3
	jr .clearPositive
.evasion
	ld a, 5
.clearPositive
	ld [wCustomStat], a
	call CustomMods
	ld a, [wCustomStat]
	ld e, a
	ld d, 0
	add hl, de
	ld a, [hl]
	cp 8
	ret c
	ld b, a
	ld a, 7
	sub b
	ld [wCustomDelta], a
	xor a
	ld [wCustomChanged], a
	jp CustomChangeStage

UtilitySelfEffect:
	ld a, [wMoveMissed]
	and a
	ret nz
	call CustomSetActor
	ld a, 2
	ld [wCustomStat], a
	ld a, 1
	ld [wCustomDelta], a
	xor a
	ld [wCustomChanged], a
	jp CustomChangeStage

UtilityBreakScreens:
	call UtilityStatus3Pointer
	res HAS_REFLECT_UP, [hl]
	res HAS_LIGHT_SCREEN_UP, [hl]
	ld hl, UtilityScreensText
	jp PrintText

UtilityStatusEffect:
	call UtilityLoadMove
	cp CAUTERIZE
	jp z, UtilityCauterize
	cp COIL
	jp z, UtilityCoil
	cp PSYCH_UP
	jp z, UtilityPsychUp
	call CustomSetTarget
	call CaptureCustomTargetSubstitute
	ld a, [wCustomTargetHadSub]
	and a
	jp nz, CustomFailed
	callab MoveHitTest
	ld a, [wMoveMissed]
	and a
	jp nz, CustomFailed
	callab PlayCurrentMoveAnimation
	ld a, [wCustomMove]
	cp WILL_O_WISP
	ld a, 1 << BRN
	jr z, .status
	ld a, 1 << FRZ
.status
	ld [wCustomDelta], a
	call UtilityInflictStatus
	ld a, [wCustomChanged]
	and a
	jp z, CustomFailed
	ret

UtilityCoil:
	call CustomSetActor
	callab PlayCurrentMoveAnimation
	xor a
	ld [wCustomChanged], a
	ld [wCustomStat], a
	ld a, 1
	ld [wCustomDelta], a
	call CustomChangeStage
	ld a, 1
	ld [wCustomStat], a
	call CustomChangeStage
	ld a, 4
	ld [wCustomStat], a
	call CustomChangeStage
	jp CustomStatusDone

; Psych Up is self-directed copying: Substitute/Mist do not block it. It has
; no accuracy roll, but Fly/Dig remain unreachable. Copy all six stages only.
UtilityPsychUp:
	call UtilityTargetStatus1
	bit INVULNERABLE, [hl]
	jp nz, CustomFailed
	call CustomSetTarget
	call CustomMods
	push hl
	call CustomSetActor
	call CustomMods
	ld d, h
	ld e, l
	pop hl
	ld b, 6
	xor a
	ld [wCustomChanged], a
.copy
	ld a, [de]
	cp [hl]
	jr z, .same
	ld a, 1
	ld [wCustomChanged], a
.same
	ld a, [hli]
	ld [de], a
	inc de
	dec b
	jr nz, .copy
	ld a, [wCustomChanged]
	and a
	jp z, CustomFailed
	callab PlayCurrentMoveAnimation
	call CustomRecalculate
	ld hl, UtilityCopiedText
	jp PrintText

UtilityStatusPointer:
	ld hl, wBattleMonStatus
	ld a, [wCustomSide]
	and a
	ret z
	ld hl, wEnemyMonStatus
	ret
UtilityStatus3Pointer:
	ld hl, wPlayerBattleStatus3
	ld a, [wCustomSide]
	and a
	ret z
	ld hl, wEnemyBattleStatus3
	ret
UtilityToxicPointer:
	ld hl, wPlayerToxicCounter
	ld a, [wCustomSide]
	and a
	ret z
	ld hl, wEnemyToxicCounter
	ret
UtilityTargetStatus1:
	ld hl, wEnemyBattleStatus1
	ld a, [H_WHOSETURN]
	and a
	ret z
	ld hl, wPlayerBattleStatus1
	ret

; One ailment per application. Only Poison Fang may upgrade ordinary poison.
UtilityInflictStatus:
	xor a
	ld [wCustomChanged], a
	call UtilityStatusPointer
	ld a, [hl]
	ld b, a
	ld a, [wCustomDelta]
	cp 1 << PSN
	jr z, .poisonStatus
	ld a, b
	and a
	ret nz
	jr .types
.poisonStatus
	ld a, b
	and a
	jr z, .types
	cp 1 << PSN
	ret nz
	push hl
	call UtilityStatus3Pointer
	bit BADLY_POISONED, [hl]
	pop hl
	ret nz
.types
	push hl
	inc hl
	ld a, [wCustomDelta]
	ld b, FIRE
	cp 1 << BRN
	jr z, .immuneType
	ld b, ICE
	cp 1 << FRZ
	jr z, .immuneType
	ld b, ELECTRIC
	cp 1 << PAR
	jr z, .immuneType
	ld b, POISON
.immuneType
	ld a, [hli]
	cp b
	jr z, .immune
	ld a, [hl]
	cp b
	jr z, .immune
	pop hl
	ld a, [wCustomDelta]
	ld [hl], a
	cp 1 << PSN
	jr nz, .notToxic
	call UtilityStatus3Pointer
	set BADLY_POISONED, [hl]
	call UtilityToxicPointer
	ld [hl], 0
.notToxic
	ld a, 1
	ld [wCustomChanged], a
	call CustomRecalculate
	call UtilitySyncParty
	ld a, [wCustomDelta]
	cp 1 << FRZ
	jr nz, .message
	callab ClearHyperBeam
.message
	ld a, [wCustomDelta]
	ld hl, UtilityBurnedText
	cp 1 << BRN
	jr z, .print
	ld hl, UtilityFrozenText
	cp 1 << FRZ
	jr z, .print
	ld hl, UtilityParalyzedText
	cp 1 << PAR
	jr z, .print
	ld hl, UtilityToxicText
.print
	jp PrintText
.immune
	pop hl
	ret

; Keep both HP and major status in sync. Wild enemies have no trainer roster.
UtilitySyncParty:
	ld a, [wCustomSide]
	and a
	jr nz, .enemy
	ld hl, wPartyMon1Status
	ld a, [wPlayerMonNumber]
	ld bc, wPartyMon2 - wPartyMon1
	jr .offset
.enemy
	ld a, [wIsInBattle]
	cp 2
	ret nz
	ld hl, wEnemyMon1Status
	ld a, [wEnemyMonPartyPos]
	ld bc, wEnemyMon2 - wEnemyMon1
.offset
	call AddNTimes
	ld d, h
	ld e, l
	call UtilityStatusPointer
	ld a, [hl]
	ld [de], a
	dec hl
	dec hl
	dec hl
	dec de
	dec de
	dec de
	ld bc, 2
	jp CopyData

UtilityCauterize:
	call CustomSetActor
	callab PlayCurrentMoveAnimation
	call UtilityStatusPointer
	xor a
	ld [hl], a
	call UtilityStatus3Pointer
	res BADLY_POISONED, [hl]
	call UtilityToxicPointer
	ld [hl], 0
	call CustomRecalculate
	ld hl, wBattleMonHP
	ld de, wBattleMonMaxHP
	ld a, [wCustomSide]
	and a
	jr z, .hp
	ld hl, wEnemyMonHP
	ld de, wEnemyMonMaxHP
.hp
	push hl
	ld a, [de]
	ld b, a
	inc de
	ld a, [de]
	ld c, a
	push bc
	ld h, b
	ld l, c
	srl h
	rr l
	srl h
	rr l
	ld a, h
	or l
	jr nz, .amount
	inc l
.amount
	pop bc ; maximum HP
	pop de ; current HP pointer
	push bc
	push de
	ld a, [de]
	ld b, a
	inc de
	ld a, [de]
	ld c, a
	add hl, bc
	pop de
	pop bc
	jr c, .cap
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
	ld a, h
	ld [de], a
	inc de
	ld a, l
	ld [de], a
	call UtilitySyncParty
	callab DrawHUDsAndHPBars
	ld hl, UtilityRecoveredText
	jp PrintText

UtilityScreensText:
	text "The protective"
	line "screens broke!"
	prompt
UtilityCopiedText:
	text "Stat stages"
	line "were copied!"
	prompt
UtilityRecoveredText:
	text "<USER>"
	line "was treated!"
	prompt
UtilityBurnedText:
	TX_FAR _BurnedText
	db "@"
UtilityFrozenText:
	TX_FAR _FrozenText
	db "@"
UtilityParalyzedText:
	TX_FAR _ParalyzedMayNotAttackText
	db "@"
UtilityToxicText:
	TX_FAR _BadlyPoisonedText
	db "@"

UtilityAIStatusScore:
	xor a
	ld [wCustomRandomValue], a
	ld a, [wEnemyMoveNum]
	cp CAUTERIZE
	jr z, .cauterize
	cp COIL
	jr z, .coil
	cp PSYCH_UP
	jr z, .psychUp
	ld a, [wPlayerBattleStatus2]
	bit HAS_SUBSTITUTE_UP, a
	jp nz, .useless
	ld a, [wPlayerBattleStatus1]
	bit INVULNERABLE, a
	jp nz, .useless
	ld a, [wBattleMonStatus]
	and a
	jr nz, .useless
	ld a, [wEnemyMoveNum]
	cp WILL_O_WISP
	ld b, FIRE
	jr z, .types
	ld b, ICE
.types
	ld a, [wBattleMonType1]
	cp b
	jr z, .useless
	ld a, [wBattleMonType2]
	cp b
	jr z, .useless
	ret
.cauterize
	ld a, [wEnemyMonStatus]
	and a
	ret nz
	ld hl, wEnemyMonHP
	ld de, wEnemyMonMaxHP
	ld a, [de]
	cp [hl]
	ret nz
	inc hl
	inc de
	ld a, [de]
	cp [hl]
	ret nz
	jr .useless
.coil
	ld a, [wEnemyMonAttackMod]
	cp 13
	ret c
	ld a, [wEnemyMonDefenseMod]
	cp 13
	ret c
	ld a, [wEnemyMonAccuracyMod]
	cp 13
	ret c
	jr .useless
.psychUp
	ld a, [wPlayerBattleStatus1]
	bit INVULNERABLE, a
	jr nz, .useless
	ld hl, wEnemyMonStatMods
	ld de, wPlayerMonStatMods
	ld b, 6
.compare
	ld a, [de]
	cp [hl]
	jr z, .next
	jr nc, .useful
.next
	inc hl
	inc de
	dec b
	jr nz, .compare
	jr .useless
.useful
	ret
.useless
	ld a, 1
	ld [wCustomRandomValue], a
	ret
