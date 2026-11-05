SECTION "Natural thawing", ROMX, BANK[$33]

; Called once from the frozen user's action-time status check.
; Carry means thawed; the caller continues through its normal status checks.
TryNaturalThaw:
	ld a, [H_WHOSETURN]
	and a
	ld hl, wBattleMonStatus
	jr z, .checkFrozen
	ld hl, wEnemyMonStatus
.checkFrozen
	bit FRZ, [hl]
	jr z, .unchanged
	callba NaturalThawRoll
	ret nc
	ld a, [H_WHOSETURN]
	and a
	jr nz, .enemy
	ld hl, wBattleMonStatus
	res FRZ, [hl]
	ld a, [wPlayerMonNumber]
	ld hl, wPartyMon1Status
	ld bc, wPartyMon2 - wPartyMon1
	call AddNTimes
	res FRZ, [hl]
	jr .message
.enemy
	ld hl, wEnemyMonStatus
	res FRZ, [hl]
	ld a, [wIsInBattle]
	cp 2
	jr nz, .message ; wild opponents have no trainer party to update
	ld a, [wEnemyMonPartyPos]
	ld hl, wEnemyMon1Status
	ld bc, wEnemyMon2 - wEnemyMon1
	call AddNTimes
	res FRZ, [hl]
.message
	ld hl, NaturallyThawedText
	call PrintText
	scf
	ret
.unchanged
	and a
	ret

NaturallyThawedText:
	TX_FAR _NaturallyThawedText
	db "@"
