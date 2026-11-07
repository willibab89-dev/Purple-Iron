SECTION "Compound move effects", ROMX, BANK[$34]

; Old handlers run in the battle bank. The table lives here to free space there.
; Use a 16-bit pointer offset so future effect IDs do not wrap at 129.
DispatchMoveEffect:
	call CustomActorMove
	ld a, [de]
	cp RESIDUAL_STATUS_EFFECT
	jp z, ResidualStatusEffect
	cp RESIDUAL_HIT_EFFECT
	jp z, ResidualHitEffect
	call CustomActorMove
	ld a, [de]
	cp UTILITY_STATUS_EFFECT
	jp z, UtilityStatusEffect
	cp UTILITY_HIT_EFFECT
	jp z, UtilityHitEffect
	cp UTILITY_SELF_EFFECT
	jp z, UtilitySelfEffect
	cp ATTACK_AND_STAT_EFFECT
	jp z, CustomAttackEffect
	cp COMPOUND_STATUS_EFFECT
	jp z, CustomStatusEffect
	cp ATTACK_AND_SELF_DROP_EFFECT
	jp z, CustomSelfDropEffect
	and a
	ret z
	dec a
	ld c, a
	ld b, 0
	sla c
	rl b
	ld hl, MoveEffectPointerTable
	add hl, bc
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld b, BANK(BattleCore)
	jp Bankswitch

INCLUDE "engine/battle/legacy_effect_table.asm"

; hl = actor move number, de = actor effect. No far-call return value needed.
CustomActorMove:
	ld hl, wPlayerMoveNum
	ld de, wPlayerMoveEffect
	ld a, [H_WHOSETURN]
	and a
	ret z
	ld hl, wEnemyMoveNum
	ld de, wEnemyMoveEffect
	ret

CaptureCustomTargetSubstitute:
	callab CheckTargetSubstitute
	ld a, 0
	jr z, .store
	inc a
.store
	ld [wCustomTargetHadSub], a
	ret

CustomSetActor:
	ld a, [H_WHOSETURN]
	ld [wCustomSide], a
	ret

CustomSetTarget:
	ld a, [H_WHOSETURN]
	xor 1
	ld [wCustomSide], a
	ret

CustomMods:
	ld hl, wPlayerMonStatMods
	ld a, [wCustomSide]
	and a
	ret z
	ld hl, wEnemyMonStatMods
	ret

CustomTargetProtected:
	ld a, [wCustomTargetHadSub]
	and a
	ret nz
	ld hl, wPlayerBattleStatus2
	ld a, [wCustomSide]
	and a
	jr z, .mist
	ld hl, wEnemyBattleStatus2
.mist
	bit PROTECTED_BY_MIST, [hl]
	ret

CustomAttackEffect:
	ld a, [wMoveMissed]
	and a
	ret nz
	ld a, [wCustomTargetHadSub]
	and a
	ret nz
	call CustomSetTarget
	ld hl, wBattleMonHP
	ld a, [wCustomSide]
	and a
	jr z, .hp
	ld hl, wEnemyMonHP
.hp
	ld a, [hli]
	or [hl]
	ret z
	call CustomActorMove
	ld a, [hl]
	ld hl, CustomAttackTable
.find
	cp [hl]
	jr z, .found
	ld bc, 4
	add hl, bc
	jr .find
.found
	inc hl
	ld a, [hli]
	ld [wCustomStat], a
	ld a, [hli]
	ld [wCustomDelta], a
	ld a, [hl]
	cp 255 ; sentinel for guaranteed; do not consume an extra random roll
	jr z, .success
	ld [wCustomChance], a
	; Store RNG before returning across the bank boundary.
	call CustomRandom
	ld a, [wCustomChance]
	ld b, a
	ld a, [wCustomRandomValue]
	cp b
	ret nc
.success
	ld a, [wCustomStat]
	cp 6
	jp z, CustomConfuse
	call CustomTargetProtected
	ret nz
	xor a
	ld [wCustomChanged], a
	jp CustomChangeStage

; move, stat (0..5; 6 = confusion), signed stage change, probability/256
CustomAttackTable:
	db TONGUE_LASH, 3, -1, 255
	db LUNGE, 0, -1, 255
	db SHELL_BREAK, 1, -1, 255
	db WAILING_CRY, 3, -1, 255
	db ROCK_TOMB, 2, -1, 255
	db ICY_WIND, 2, -1, 255
	db SLAM,         1, -1, 255
	db BIND,         2, -1, 255
	db CONSTRICT,    2, -1, 255
	db BUBBLEBEAM,   2, -1, 255
	db STRING_SHOT,  2, -1, 255
	db SAND_ATTACK,  4, -1, 255
	db FLASH,        4, -1, 128
	db PETAL_DANCE,  5, -1, 255
	db FISSURE,      0, -2, 255
	db HORN_DRILL,   1, -2, 255
	db GUILLOTINE,   3, -2, 255
	db BUBBLE,       2, -1, 77
	db DIZZY_PUNCH,  6,  0, 77
	db COMET_PUNCH,  6,  0, 255

CustomSelfDropEffect:
	ld a, [wMoveMissed]
	and a
	ret nz
	call CustomSetActor
	xor a
	ld [wCustomStat], a
	ld [wCustomChanged], a
	dec a
	ld [wCustomDelta], a
	jp CustomChangeStage

CustomStatusEffect:
	call CustomActorMove
	ld a, [hl]
	ld [wCustomMove], a
	cp KINESIS
	jr z, .target
	cp SPLASH
	jr z, .target
	call CustomSetActor
	jr .ready
.target
	call CustomSetTarget
	call CaptureCustomTargetSubstitute
	call CustomTargetProtected
	jp nz, CustomFailed
	callab MoveHitTest
	ld a, [wMoveMissed]
	and a
	jp nz, CustomFailed
.ready
	callab PlayCurrentMoveAnimation
	xor a
	ld [wCustomChanged], a
	ld a, [wCustomMove]
	cp AMNESIA
	jp z, CustomAmnesia
	ld hl, CustomStatusTable
.find
	cp [hl]
	jr z, .found
	ld bc, 5
	add hl, bc
	jr .find
.found
	inc hl
	call .one
	call .one
	jr CustomStatusDone
.one
	ld a, [hli]
	ld [wCustomStat], a
	ld a, [hli]
	ld [wCustomDelta], a
	push hl
	call CustomChangeStage
	pop hl
	ret

CustomStatusTable:
	db QUIVER_DANCE, 3, 1, 2, 1
	db STOCKPILE, 1, 1, 3, 1
	db BULK_UP, 0, 1, 1, 1
	db CHARGE, 3, 1, 4, 1
	db DRAGON_DANCE, 0, 1, 2, 1
	db GROWTH,   3,  1, 1,  1
	db KINESIS,  4, -1, 0, -1
	db MEDITATE, 0,  1, 2,  1
	db WITHDRAW, 1,  1, 4,  1
	db SPLASH,   0, -1, 4, -1
	db SHARPEN,  0,  1, 4,  1

CustomAmnesia:
	call CustomMods
	ld b, 6
.loop
	ld a, [hl]
	cp 7
	jr nc, .next
	ld [hl], 7
	ld a, 1
	ld [wCustomChanged], a
.next
	inc hl
	dec b
	jr nz, .loop
	ld a, 3
	ld [wCustomStat], a
	ld a, 1
	ld [wCustomDelta], a
	call CustomChangeStage
	; Negative stages may have changed even if Special was already at +6.
	ld a, [wCustomChanged]
	and a
	call nz, CustomRecalculate
CustomStatusDone:
	ld a, [wCustomChanged]
	and a
	ret nz
CustomFailed:
	jpab PrintButItFailedText_

; Stage caps are independent. No second hit test, animation, or RNG here.
CustomChangeStage:
	call CustomMods
	ld a, [wCustomStat]
	ld e, a
	ld d, 0
	add hl, de
	ld b, [hl]
	ld a, [wCustomDelta]
	add b
	bit 7, a
	jr nz, .minimum
	cp 1
	jr nc, .maximum
.minimum
	ld a, 1
.maximum
	cp 14
	jr c, .bounded
	ld a, 13
.bounded
	cp b
	ret z
	ld [hl], a
	ld a, 1
	ld [wCustomChanged], a
	call CustomRecalculate
	callab CustomPrintStatName
	ld a, [H_WHOSETURN]
	ld [wCustomSavedTurn], a
	ld a, [wCustomDelta]
	bit 7, a
	jr nz, .fell
	ld a, [wCustomSide]
	ld [H_WHOSETURN], a
	ld hl, CustomRoseText
	jr .print
.fell
	ld a, [wCustomSide]
	xor 1
	ld [H_WHOSETURN], a
	ld hl, CustomFellText
.print
	call PrintText
	ld a, [wCustomSavedTurn]
	ld [H_WHOSETURN], a
	ret

; Rebuild all four from unmodified stats, then apply badge/status modifiers once.
CustomRecalculate:
	ld a, [wCustomSide]
	ld [wCalculateWhoseStats], a
	callab CalculateModifiedStats
	ld a, [wCustomSide]
	and a
	jr nz, .penalties
	xor a
	ld [wUnusedD71B], a
	callab ApplyBadgeStatBoosts
.penalties
	ld a, [H_WHOSETURN]
	push af
	ld a, [wCustomSide]
	xor 1
	ld [H_WHOSETURN], a
	callab HalveAttackDueToBurn
	callab QuarterSpeedDueToParalysis
	pop af
	ld [H_WHOSETURN], a
	ret

CustomConfuse:
	ld hl, wPlayerBattleStatus1
	ld de, wPlayerConfusedCounter
	ld a, [wCustomSide]
	and a
	jr z, .target
	ld hl, wEnemyBattleStatus1
	ld de, wEnemyConfusedCounter
.target
	bit CONFUSED, [hl]
	ret nz
	set CONFUSED, [hl]
	push de
	call CustomRandom
	pop de
	ld a, [wCustomRandomValue]
	and 3
	add 2
	ld [de], a
	ld hl, CustomConfusedText
	jp PrintText

CustomRandom:
	jpab CustomRandomInBattleBank

CustomRoseText:
	TX_FAR _MonsStatsRoseText
	TX_FAR _RoseText
	db "@"
CustomFellText:
	TX_FAR _MonsStatsFellText
	TX_FAR _FellText
	db "@"
CustomConfusedText:
	TX_FAR _BecameConfusedText
	db "@"

; AI consults the same compound metadata. Result 1 = move has no useful stage
; changes, 0 = at least one can work. Preserve caller registers at the call site.
CustomAIStatusScore:
	xor a
	ld [wCustomRandomValue], a
	ld a, [wEnemyMoveNum]
	ld [wCustomMove], a
	ld a, 1
	ld [wCustomSide], a
	ld a, [wCustomMove]
	cp KINESIS
	jr z, .target
	cp SPLASH
	jr nz, .self
.target
	xor a
	ld [wCustomSide], a
	ld a, [wPlayerBattleStatus2]
	and (1 << HAS_SUBSTITUTE_UP) | (1 << PROTECTED_BY_MIST)
	jr nz, .useless
	ld a, [wPlayerBattleStatus1]
	bit INVULNERABLE, a
	jr nz, .useless
.self
	ld a, [wCustomMove]
	cp AMNESIA
	jr nz, .table
	call CustomMods
	ld b, 6
.negative
	ld a, [hli]
	cp 7
	ret c
	dec b
	jr nz, .negative
	ld a, [wEnemyMonSpecialMod]
	cp 13
	ret c
	jr .useless
.table
	ld hl, CustomStatusTable
	ld a, [wCustomMove]
.find
	cp [hl]
	jr z, .found
	ld bc, 5
	add hl, bc
	jr .find
.found
	inc hl
	call .canChange
	ret c
	call .canChange
	ret c
.useless
	ld a, 1
	ld [wCustomRandomValue], a
	ret
.canChange
	ld a, [hli]
	ld [wCustomStat], a
	ld a, [hli]
	ld [wCustomDelta], a
	push hl
	call CustomMods
	ld a, [wCustomStat]
	ld e, a
	ld d, 0
	add hl, de
	ld a, [wCustomDelta]
	bit 7, a
	ld a, [hl]
	jr nz, .down
	cp 13
	jr .return
.down
	cp 2
	ccf
.return
	pop hl
	ret
