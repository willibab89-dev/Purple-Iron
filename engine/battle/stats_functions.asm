
; does nothing since no stats are ever selected (barring glitches)
;joenote - let's get this working again and put it to use
DoubleSelectedStats:
	ld a, [H_WHOSETURN]
	and a
	ld a, [wPlayerStatsToDouble]
	ld hl, wBattleMonAttack
	jr z, .notEnemyTurn
	ld a, [wEnemyStatsToDouble]
	ld hl, wEnemyMonAttack
.notEnemyTurn
	ld c, 4
	ld b, a
.loop
	srl b
	call c, .doubleStat
	inc hl
	inc hl
	dec c
	ret z
	jr .loop
.doubleStat
	push bc
	ld a, [hli]
	ld b, a
	ld c, [hl] ; bc holds value of stat to double
;double the stat
	sla c
	rl b
;cap stat at 999
	;b register contains high byte & c register contains low byte
	ld a, c ;let's work on low byte first. Note that decimal 999 is $03E7 in hex.
	sub 999 % $100 ;a = a - ($03E7 % $100). Gives a = a - $E7. A byte % $100 always gives the lesser nibble.
	;Note that if a < $E7 then the carry bit 'c' in the flag register gets set due to overflowing with a negative result.
	ld a, b ;now let's work on the high byte
	sbc 999 / $100 ;a = a - ($03E7 / $100 + c_flag). Gives a = a - ($03 + c_flag). A byte / $100 always gives the greater nibble.
	;Note again that if a < $03 then the carry bit remains set. 
	;If the bit is already set from the lesser nibble, then its addition here can still make it remain set if a is low enough.
	jr c, .donecapping ;jump to next marker if the c_flag is set. This only remains set if BC <  the cap of $03E7.
	;else let's continue and set the 999 cap
	ld a, 999 / $100 ; else load $03 into a
	ld b, a ;and store it as the high byte
	ld a, 999 % $100 ; else load $E7 into a
	ld c, a ;and store it as the low byte
	;now registers b & c together contain $03E7 for a capped stat value of 999
.donecapping
	ld a, c
	ld [hld], a
	ld [hl], b
	pop bc
	ret

	
	
; does nothing since no stats are ever selected (barring glitches)
;joenote - let's get this working again and put it to use
HalveSelectedStats:
	ld a, [H_WHOSETURN]
	and a
	ld a, [wPlayerStatsToHalve]
	ld hl, wBattleMonAttack
	jr z, .notEnemyTurn
	ld a, [wEnemyStatsToHalve]
	ld hl, wEnemyMonAttack
.notEnemyTurn
	ld c, 4
	ld b, a
.loop
	srl b
	call c, .halveStat
	inc hl
	inc hl
	dec c
	ret z
	jr .loop
.halveStat
	ld a, [hl]
	srl a
	ld [hli], a
	rr [hl]
	or [hl]
	jr nz, .nonzeroStat
	ld [hl], 1
.nonzeroStat
	dec hl
	ret

	
 ; Rebuild staged/nature-adjusted stats before a cure. This restores exact
; values after burn, paralysis or poison without reversing rounded penalties.
UndoBurnParStats:
	ld a, [wIsInBattle]
	and a
	ret z
	abilitycall RestoreCuredStatusStats
	ret

;joenote - this function is meant to temporarily reduce a a pkmn's speed by 25% for using trapping moves until stats are recalculated
;"c" holds lower byte of speed and "b" holds upper byte of speed
ReduceSpeed:
	push bc
	push de
	ld hl, wBattleMonSpeed + 1	;assume it is the player's turn
	ld a, [H_WHOSETURN]
	and a
	jr z, .proceed
	ld hl, wEnemyMonSpeed + 1	;else it's the enemy's turn
.proceed
	;bc to hold regular speed and de to hold 25% of that
	ld a, [hld]
	ld c, a
	ld e, a
	ld a, [hl]
	ld b, a
	ld d, a
	;make de one-quarter of bc
	srl d
	rr e
	srl d
	rr e
	;now subtract e from c
	ld a, c
	sub e
	ld c, a
	;now subtract d from b with carry
	ld a, b
	sbc d
	ld b, a
	;a still holds upper speed byte, so save it back
	ld [hli], a
	;now OR the upper speed byte in a with the lower speed byte
	or c	;zero flag is set if speed is totally zero
	jr nz, .notzerospeed
	ld c, 1	;give minimum of at least 1 in speed
.notzerospeed
	ld [hl], c
	pop de
	pop bc
	ret

;joenote - this function puts statexp per enemy pkmn level into de
;requires a, b, de, and wCurEnemyLVL
CalcEnemyStatEXP:
	ld a, [wOptions]	;load game options
	bit 6, a			;check battle style
	jr z, .loadzero		;load zero stat exp if on shift style
	;This loads 648 stat exp per level. Note that 648 in hex is the two-byte $0288
	ld a, $02
	ld [H_MULTIPLICAND], a
	ld a, $88
	ld [H_MULTIPLICAND + 1], a
	xor a
	ld [H_MULTIPLICAND + 2], a
	ld a, [wCurEnemyLVL]
	ld [H_MULTIPLIER], a
	call Multiply
	ld a, [H_MULTIPLICAND]
	ld d, a
	ld a, [H_MULTIPLICAND+1]
	ld e, a
	ret
.loadzero
	xor a
	ld d, a
	ld e, a
	ret
	
;	;Alternative algorithm: adds (12 stat exp * current level) per level.
;	ld a, [wCurEnemyLVL]
;	ld b, a	;put the enemy's level into b. it will be used as a loop counter
;	xor a	;make a = 0
;	ld d, a	;clear d (use for MSB)
;	ld e, a ;clear e (use for LSB)
;.loop
;	ld a, d
;	cp a, $FF	;see if the current value of de is 65280 or more
;	jr z, .skipadder
;	push hl
;	push bc
;	xor a
;	ld [H_MULTIPLICAND], a
;	ld a, [wCurEnemyLVL]
;	ld [H_MULTIPLICAND + 1], a
;	ld a, $C
;	ld [H_MULTIPLIER], a
;	call Multiply
;	ld a, e
;	add l
;	ld e, a
;	ld a, d
;	adc h
;	ld d, a
;	pop bc
;	pop hl
;.skipadder
;	dec b; decrement b 
;	jr nz, .loop	;loop back if b is not zero
;	ret
	

