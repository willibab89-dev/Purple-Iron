SECTION "Move sequences and priority", ROMX, BANK[$34]

SequencePlayerPriority:
	ld a, [wPlayerSelectedMove]
	ld hl, wEnemyMonHP
	ld de, wEnemyMonMaxHP
	jr SequencePriority
SequenceEnemyPriority:
	ld a, [wEnemySelectedMove]
	ld hl, wBattleMonHP
	ld de, wBattleMonMaxHP
SequencePriority:
	cp QUICK_ATTACK
	ret z
	cp AQUA_JET
	ret z
	cp THUNDERCLAP
	ret z
	cp AMBUSH
	ret nz
	call SequenceHPBelowHalf
	jr c, .priority
	ld a, 1
	and a
	ret
.priority
	xor a
	ret

SequenceTargetBelowHalf:
	ld hl, wEnemyMonHP
	ld de, wEnemyMonMaxHP
	ld a, [H_WHOSETURN]
	and a
	jr z, SequenceHPBelowHalf
	ld hl, wBattleMonHP
	ld de, wBattleMonMaxHP
; Carry iff 2 * current HP < max HP, including odd HP maxima.
SequenceHPBelowHalf:
	ld a, [hli]
	ld l, [hl]
	ld h, a
	add hl, hl
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

; A temporary Fly/Dig status alone is insufficient: the target must be using
; Fly, and this must be the real Twister record, not confusion self-damage.
SequenceAirborneHit:
	call CustomActorMove
	ld a, [hl]
	cp RAZOR_WIND
	jr nz, .no
	inc hl
	inc hl
	ld a, [hli]
	cp 40
	jr nz, .no
	ld a, [hl]
	cp DRAGON
	jr nz, .no
	ld hl, wEnemyBattleStatus1
	ld de, wEnemyMoveNum
	ld a, [H_WHOSETURN]
	and a
	jr z, .target
	ld hl, wPlayerBattleStatus1
	ld de, wPlayerMoveNum
.target
	bit INVULNERABLE, [hl]
	jr z, .no
	ld a, [de]
	cp FLY
	jr nz, .no
	scf
	ret
.no
	and a
	ret

; Keep the Rage flag through the opponent's remaining action on the final
; turn. Expire before the next round's command selection, not mid-round.
SequenceNewRound:
	ld hl, wPlayerBattleStatus1
	ld de, wPlayerNumAttacksLeft
	call SequenceBideClock
	ld hl, wEnemyBattleStatus1
	ld de, wEnemyNumAttacksLeft
	call SequenceBideClock
	ld hl, wPlayerBattleStatus1
	res FLINCHED, [hl]
	ld hl, wEnemyBattleStatus1
	res FLINCHED, [hl]
	ld hl, wPlayerBattleStatus2
	ld de, wPlayerNumAttacksLeft
	call .expire
	ld hl, wEnemyBattleStatus2
	ld de, wEnemyNumAttacksLeft
.expire
	bit USING_RAGE, [hl]
	ret z
	ld a, [de]
	and a
	ret nz
	res USING_RAGE, [hl]
	ret

SequenceBeginRage:
	call CustomActorMove
	ld a, [hl]
	cp RAGE
	ret nz
	ld hl, wPlayerBattleStatus2
	ld de, wPlayerNumAttacksLeft
	ld a, [H_WHOSETURN]
	and a
	jr z, .actor
	ld hl, wEnemyBattleStatus2
	ld de, wEnemyNumAttacksLeft
.actor
	bit USING_RAGE, [hl]
	ret nz
	set USING_RAGE, [hl]
	push de
	call CustomRandom
	pop de
	ld a, [wCustomRandomValue]
	and 1
	add 2
	ld [de], a
	ret

SequenceFinishPlayerAction:
	ld hl, wPlayerBattleStatus2
	ld de, wPlayerNumAttacksLeft
	jr SequenceFinishAction
SequenceFinishEnemyAction:
	ld hl, wEnemyBattleStatus2
	ld de, wEnemyNumAttacksLeft
SequenceFinishAction:
	bit USING_RAGE, [hl]
	ret z
	ld a, [de]
	and a
	ret z
	dec a
	ld [de], a
	ret

SequenceReloadPlayerRage:
	ld a, RAGE
	ld [wPlayerSelectedMove], a
	jpab GetCurrentMove
SequenceReloadEnemyRage:
	ld a, RAGE
	ld [wEnemySelectedMove], a
	jpab GetCurrentMove

SequenceRageBoost:
	ld a, [wCustomTargetHadSub]
	and a
	ret nz
	ld a, [wMoveMissed]
	and a
	ret nz
	ld a, [wDamage]
	ld b, a
	ld a, [wDamage + 1]
	or b
	ret z
	ld hl, wEnemyBattleStatus2
	ld a, [H_WHOSETURN]
	and a
	jr z, .target
	ld hl, wPlayerBattleStatus2
.target
	bit USING_RAGE, [hl]
	ret z
	call CustomSetTarget
	xor a
	ld [wCustomStat], a
	ld [wCustomChanged], a
	inc a
	ld [wCustomDelta], a
	jp CustomChangeStage

SequenceFuryAccuracyMiss:
	ld a, [wMoveMissed] ; an earlier type-immunity failure must not grant a boost
	and a
	ret nz
	call CustomActorMove
	ld a, [hl]
	cp FURY_SWIPES
	ret nz
	call CustomSetActor
	xor a
	ld [wCustomStat], a
	ld [wCustomChanged], a
	inc a
	ld [wCustomDelta], a
	jp CustomChangeStage

SequenceSkullBashBoost:
	call CustomActorMove
	ld a, [hl]
	cp SKULL_BASH
	ret nz
	call CustomSetActor
	ld a, 1
	ld [wCustomStat], a
	ld a, 2
	ld [wCustomDelta], a
	xor a
	ld [wCustomChanged], a
	jp CustomChangeStage

SequenceCancelCharge:
	ld hl, wPlayerBattleStatus1
	ld a, [H_WHOSETURN]
	and a
	jr z, .actor
	ld hl, wEnemyBattleStatus1
.actor
	res CHARGING_UP, [hl]
	res INVULNERABLE, [hl]
	ret

; Store for two global turns, even if an item/status delays the release.
; Pending release can wait for an action, but cannot collect extra damage.
SequenceBideClock:
	bit STORING_ENERGY, [hl]
	ret z
	ld a, [de]
	and a
	ret z
	dec a
	ld [de], a
	ret
