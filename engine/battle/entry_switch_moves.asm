SECTION "Entry transformation and forced switching", ROMX, BANK[$34]

; Residual flags bit 3 records an entry attempt, independently of Haze.
; New active data clears it through the existing replacement cleanup.
EntryAutoBoth:
	ld a, [H_WHOSETURN]
	push af
	xor a
	ld [H_WHOSETURN], a
	call EntryAutoOne
	ld a, 1
	ld [H_WHOSETURN], a
	call EntryAutoOne
	pop af
	ld [H_WHOSETURN], a
	ret
EntryAutoOne:
	call CustomSetActor
	call ResidualAlive
	ret z
	call CustomSetTarget
	call ResidualAlive
	ret z
	call CustomSetActor
	call ResidualState
	bit 3, [hl]
	ret nz
	set 3, [hl]
	ld hl, wPlayerBattleStatus3
	ld de, wBattleMonSpecies
	ld a, [H_WHOSETURN]
	and a
	jr z, .actor
	ld hl, wEnemyBattleStatus3
	ld de, wEnemyMonSpecies
.actor
	bit TRANSFORMED, [hl]
	ret nz
	ld a, [de]
	cp DITTO
	jr z, .ditto
	cp UNIQUE_DITTO_HAPPY
	ret nz
.ditto
	ld hl, wEnemyBattleStatus3
	ld de, wEnemyMonSpecies
	ld a, [H_WHOSETURN]
	and a
	jr z, .target
	ld hl, wPlayerBattleStatus3
	ld de, wBattleMonSpecies
.target
	bit TRANSFORMED, [hl]
	ret nz
	ld a, [de]
	cp DITTO
	ret z
	cp UNIQUE_DITTO_HAPPY
	ret z
	call UtilityTargetStatus1
	bit INVULNERABLE, [hl]
	ret nz
	callab CheckTargetSubstitute
	ret nz
	; Animation must use Transform without consuming a selected move or PP.
	call CustomActorMove
	ld a, [hl]
	push af
	ld [hl], TRANSFORM
	callab TransformEffect_
	call CustomActorMove
	pop af
	ld [hl], a
	ret

; Z means fall through to the existing wild escape/Teleport implementation.
; NZ means a trainer Roar/Whirlwind was handled, including failure.
EntryTryPhaze:
	call CustomActorMove
	ld a, [hl]
	cp ROAR
	jr z, .phazeMove
	cp WHIRLWIND
	jr z, .phazeMove
	xor a
	ret
.phazeMove
	ld a, [wIsInBattle]
	cp 2
	jr z, .trainer
	xor a
	ret
.trainer
	; Random replacement commands have no link protocol in this patch.
	ld a, [wLinkState]
	cp LINK_STATE_BATTLING
	jp z, .failed
	callab CheckTargetSubstitute
	jp nz, .failed
	call UtilityTargetStatus1
	bit INVULNERABLE, [hl]
	jp nz, .failed
	call CustomSetTarget
	call EntryCountReserves
	ld a, [wCustomChanged]
	and a
	jp z, .failed
	callab MoveHitTest
	ld a, [wMoveMissed]
	and a
	jp nz, .failed
	callab PlayCurrentMoveAnimation
	call CustomSetTarget
	call EntryCountReserves
	call EntryChooseReserve
	ld a, [H_WHOSETURN]
	push af
	and a
	jr nz, .forcePlayer
	ld hl, wResidualRoundDone
	set 7, [hl]
	callab SwitchEnemyMon
	jr .switched
.forcePlayer
	callab ReadPlayerMonCurHPAndStatus
	ld a, [wResidualSavedEffect]
	ld [wWhichPokemon], a
	ld hl, wPartySpecies
	ld bc, 1
	call AddNTimes
	ld a, [hl]
	ld [wBattleMonSpecies2], a
	ld [wcf91], a
	callab SwitchPlayerMon
.switched
	pop af
	ld [H_WHOSETURN], a
	and a
	ld a, $ff
	jr nz, .skipPlayer
	ld [wEnemySelectedMove], a
	jr .handled
.skipPlayer
	ld [wPlayerSelectedMove], a
.handled
	ld a, 1
	and a
	ret
.failed
	call CustomFailed
	jr .handled

; Side selects the affected roster. Healthy reserves exclude the active slot.
EntryPartySize:
	ld a, [wCustomSide]
	and a
	ld a, [wPartyCount]
	ret z
	ld a, [wEnemyPartyCount]
	ret
EntryCandidateAlive:
	ld a, [wCustomStat]
	ld b, a
	ld a, [wCustomSide]
	and a
	jr nz, .enemy
	ld a, [wPlayerMonNumber]
	cp b
	ret z
	ld hl, wPartyMon1HP
	ld bc, wPartyMon2 - wPartyMon1
	jr .hp
.enemy
	ld a, [wEnemyMonPartyPos]
	cp b
	ret z
	ld hl, wEnemyMon1HP
	ld bc, wEnemyMon2 - wEnemyMon1
.hp
	ld a, [wCustomStat]
	call AddNTimes
	ld a, [hli]
	or [hl]
	ret
EntryCountReserves:
	call EntryPartySize
	ld [wCustomDelta], a
	xor a
	ld [wCustomStat], a
	ld [wCustomChanged], a
.loop
	ld a, [wCustomStat]
	ld b, a
	ld a, [wCustomDelta]
	cp b
	ret z
	call EntryCandidateAlive
	jr z, .next
	ld hl, wCustomChanged
	inc [hl]
.next
	ld hl, wCustomStat
	inc [hl]
	jr .loop
EntryChooseReserve:
	call CustomRandom
	ld a, [wCustomRandomValue]
	and 7
	ld b, a
	ld a, [wCustomChanged]
	cp b
	jr z, EntryChooseReserve
	jr c, EntryChooseReserve
	ld a, b
	ld [wCustomChance], a
	xor a
	ld [wCustomStat], a
.loop
	call EntryCandidateAlive
	jr z, .next
	ld a, [wCustomChance]
	and a
	jr z, .chosen
	dec a
	ld [wCustomChance], a
.next
	ld hl, wCustomStat
	inc [hl]
	jr .loop
.chosen
	ld a, [wCustomStat]
	ld [wResidualSavedEffect], a
	ret

; One-shot override of the enemy send-out selector. SwitchEnemyMon still owns
; roster synchronization, graphics and status reset, with no response prompt.
EntrySelectEnemy:
	ld hl, wResidualRoundDone
	bit 7, [hl]
	jp z, .ordinary
	res 7, [hl]
	ld a, [wResidualSavedEffect]
	ld [wWhichPokemon], a
	ret
.ordinary
	jpab AISelectWhichMonSendOut

EntryAIPhazeScore:
	ld a, 1
	ld [wCustomRandomValue], a
	ld a, [wEnemyMoveNum]
	cp ROAR
	jr z, .move
	cp WHIRLWIND
	ret nz ; Teleport remains unusable in trainer battles.
.move
	ld a, [wLinkState]
	cp LINK_STATE_BATTLING
	ret z
	ld a, [wPlayerBattleStatus2]
	bit HAS_SUBSTITUTE_UP, a
	ret nz
	ld a, [wPlayerBattleStatus1]
	bit INVULNERABLE, a
	ret nz
	xor a
	ld [wCustomSide], a
	call EntryCountReserves
	ld a, [wCustomChanged]
	and a
	ret z
	xor a
	ld [wCustomRandomValue], a
	ret
