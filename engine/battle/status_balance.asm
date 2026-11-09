SECTION "Status balance", ROMX, BANK[$3c]
HalveSpeedDueToParalysis:
	ld a, [H_WHOSETURN]
	and a
	jr z, .playerTurn
.enemyTurn ; halve the player's speed
	ld a, [wBattleMonStatus]
	and 1 << PAR
	ret z ; return if player not paralysed
	ld hl, wBattleMonSpeed + 1
	ld a, [hld]
	ld b, a
	ld a, [hl]
	srl a
	rr b
	ld [hli], a
	or b
	jr nz, .storePlayerSpeed
	ld b, 1 ; give the player a minimum of at least one speed point
.storePlayerSpeed
	ld [hl], b
	ret
.playerTurn ; halve the enemy's speed
	ld a, [wEnemyMonStatus]
	and 1 << PAR
	ret z ; return if enemy not paralysed
	ld hl, wEnemyMonSpeed + 1
	ld a, [hld]
	ld b, a
	ld a, [hl]
	srl a
	rr b
	ld [hli], a
	or b
	jr nz, .storeEnemySpeed
	ld b, 1 ; give the enemy a minimum of at least one speed point
.storeEnemySpeed
	ld [hl], b
	ret

StatusHalveAttackDueToBurn:
	ld a, [H_WHOSETURN]
	and a
	jr z, .playerTurn
.enemyTurn ; halve the player's attack
	ld a, [wBattleMonStatus]
	and 1 << BRN
	ret z ; return if player not burnt
	ld hl, wBattleMonAttack + 1
	ld a, [hld]
	ld b, a
	ld a, [hl]
	srl a
	rr b
	ld [hli], a
	or b
	jr nz, .storePlayerAttack
	ld b, 1 ; give the player a minimum of at least one attack point
.storePlayerAttack
	ld [hl], b
	ret
.playerTurn ; halve the enemy's attack
	ld a, [wEnemyMonStatus]
	and 1 << BRN
	ret z ; return if enemy not burnt
	ld hl, wEnemyMonAttack + 1
	ld a, [hld]
	ld b, a
	ld a, [hl]
	srl a
	rr b
	ld [hli], a
	or b
	jr nz, .storeEnemyAttack
	ld b, 1 ; give the enemy a minimum of at least one attack point
.storeEnemyAttack
	ld [hl], b
	ret


; Same target convention as burn/paralysis: turn 0 affects enemy, turn 1 player.
PoisonSpecialPenalty:
	ld hl, wEnemyMonStatus
	ld de, wEnemyMonSpecial
	ld a, [H_WHOSETURN]
	and a
	jr z, .status
	ld hl, wBattleMonStatus
	ld de, wBattleMonSpecial
.status
	bit PSN, [hl]
	ret z
	ld h, d
	ld l, e
	ld a, [hli]
	ld b, [hl]
	srl a
	rr b
	srl a
	rr b
	ld c, a
	or b
	jr nz, .store
	inc b
.store
	ld [hl], b
	dec hl
	ld [hl], c
	ret

; Rebuild rather than multiply rounded penalties back up. Called immediately
; before a cure changes the status byte; preserve it until the caller does so.
RestoreCuredStatusStats:
	ld a, [H_WHOSETURN]
	ld [wCustomSide], a
	ld hl, wBattleMonStatus
	and a
	jr z, .actor
	ld hl, wEnemyMonStatus
.actor
	ld a, [hl]
	push hl
	push af
	ld [hl], 0
	callab CustomRecalculate
	pop af
	pop hl
	ld [hl], a
	ld hl, wPlayerStatsToDouble
	ld a, [wCustomSide]
	and a
	jr z, .clearFlags
	ld hl, wEnemyStatsToDouble
.clearFlags
	ld [hl], 0
	ret
