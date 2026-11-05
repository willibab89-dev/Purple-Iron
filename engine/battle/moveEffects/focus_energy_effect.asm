FocusEnergyEffect_:
	ld hl, wPlayerBattleStatus2
	ld a, [H_WHOSETURN]
	and a
	jr z, .notEnemy
	ld hl, wEnemyBattleStatus2
.notEnemy
	ld d, h
	ld e, l
	callba RaiseFocusEnergyBoost
	jr nc, .alreadyUsing ; fail only when already at x4
	callab PlayCurrentMoveAnimation
	ld hl, GettingPumpedText
	jp PrintText
.alreadyUsing
	ld c, 50
	call DelayFrames
	jpab PrintButItFailedText_

GettingPumpedText:
	TX_DELAY
	TX_FAR _GettingPumpedText
	db "@"
