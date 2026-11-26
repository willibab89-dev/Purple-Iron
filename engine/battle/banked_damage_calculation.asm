SECTION "Banked damage calculation", ROMX, BANK[$35]

BankedCalculateDamage:
	ld a, [H_MULTIPLICAND + 1]
	ld b, a
	ld a, [H_MULTIPLICAND + 2]
	ld c, a

	xor a
	ld hl, H_DIVIDEND
	ldi [hl], a
	ldi [hl], a
	ld [hl], a

; Multiply level by 2
	ld a, e ; level
	add a
	jr nc, .nc
	push af
	ld a, 1
	ld [hl], a
	pop af
.nc
	inc hl
	ldi [hl], a

; Divide by 5
	ld a, 5
	ldd [hl], a
	push bc
	ld b, 4
	call Divide
	pop bc

; Add 2
	inc [hl]
	inc [hl]

	inc hl ; multiplier

; Multiply by attack base power
	ld [hl], d
	call Multiply

; Multiply by attack stat
	ld [hl], b
	call Multiply

; Divide by defender's defense stat
	ld [hl], c
	ld b, 4
	call Divide

; Divide by 50
	ld [hl], 50
	ld b, 4
	call Divide

	ld hl, wDamage
	ld b, [hl]
	ld a, [H_QUOTIENT + 3]
	add b
	ld [H_QUOTIENT + 3], a
	jr nc, .asm_3dfd0

	ld a, [H_QUOTIENT + 2]
	inc a
	ld [H_QUOTIENT + 2], a
	and a
	jr z, .asm_3e004

.asm_3dfd0
	ld a, [H_QUOTIENT]
	ld b, a
	ld a, [H_QUOTIENT + 1]
	or a
	jr nz, .asm_3e004

	ld a, [H_QUOTIENT + 2]
	cp 998 / $100
	jr c, .asm_3dfe8
	cp 998 / $100 + 1
	jr nc, .asm_3e004
	ld a, [H_QUOTIENT + 3]
	cp 998 % $100
	jr nc, .asm_3e004

.asm_3dfe8
	inc hl
	ld a, [H_QUOTIENT + 3]
	ld b, [hl]
	add b
	ld [hld], a

	ld a, [H_QUOTIENT + 2]
	ld b, [hl]
	adc b
	ld [hl], a
	jr c, .asm_3e004

	ld a, [hl]
	cp 998 / $100
	jr c, .asm_3e00a
	cp 998 / $100 + 1
	jr nc, .asm_3e004
	inc hl
	ld a, [hld]
	cp 998 % $100
	jr c, .asm_3e00a

.asm_3e004
; cap at 997
	ld a, 997 / $100
	ld [hli], a
	ld a, 997 % $100
	ld [hld], a

.asm_3e00a
; add 2
	inc hl
	ld a, [hl]
	add 2
	ld [hld], a
	jr nc, .done
	inc [hl]

.done
; minimum damage is 1
	ld a, 1
	and a
	ret

BankedCalcHitChance:
	abilitycall AbilityPrecisionAccuracy
	abilitycall AbilityHustleAccuracy
	ld hl, wPlayerMoveAccuracy
	ld a, [H_WHOSETURN]
	and a
	ld a, [wPlayerMonAccuracyMod]
	ld b, a
	ld a, [wEnemyMonEvasionMod]
	ld c, a
	jr z, .next
; values for enemy turn
	ld hl, wEnemyMoveAccuracy
	ld a, [wEnemyMonAccuracyMod]
	ld b, a
	ld a, [wPlayerMonEvasionMod]
	ld c, a
.next
	push hl
	push bc
	callab AbilityActor
	ld a, [wAbilityResolvedExtended]
	cp AB_MINDS_EYE - ABILITY_EXTENDED
	pop bc
	jr nz, .evasionReady
	ld c, 7
.evasionReady
	pop hl
	ld a, $0e
	sub c
	ld c, a ; c = 14 - EVASIONMOD (this "reflects" the value over 7, so that an increase in the target's evasion
	       ; decreases the hit chance instead of increasing the hit chance)
; zero the high bytes of the multiplicand
	xor a
	ld [H_MULTIPLICAND], a
	ld [H_MULTIPLICAND + 1], a
	ld a, [hl]
	ld [H_MULTIPLICAND + 2], a ; set multiplicand to move accuracy
	push hl
	ld d, $02 ; loop has two iterations
; loop to do the calculations, the first iteration multiplies by the accuracy ratio and
; the second iteration multiplies by the evasion ratio
.loop
	push bc
	ld hl, BankedStatModifierRatios  ; stat modifier ratios
	dec b
	sla b
	ld c, b
	ld b, $00
	add hl, bc ; hl = address of stat modifier ratio
	pop bc
	ld a, [hli]
	ld [H_MULTIPLIER], a ; set multiplier to the numerator of the ratio
	call Multiply
	ld a, [hl]
	ld [H_DIVISOR], a ; set divisor to the the denominator of the ratio
	                 ; (the dividend is the product of the previous multiplication)
	ld b, $04 ; number of bytes in the dividend
	call Divide
	ld a, [H_QUOTIENT + 3]
	ld b, a
	ld a, [H_QUOTIENT + 2]
	or b
	jp nz, .nextCalculation
; make sure the result is always at least one
	ld [H_QUOTIENT + 2], a
	ld a, $01
	ld [H_QUOTIENT + 3], a
.nextCalculation
	ld b, c
	dec d
	jr nz, .loop
	abilitycall NatureApplyHitChance
	abilitycall AbilityAccuracy
	ld a, [H_QUOTIENT + 2]
	and a ; is the calculated hit chance over 0xFF?
	ld a, [H_QUOTIENT + 3]
	jr z, .storeAccuracy
; if calculated hit chance over 0xFF
	ld a, $ff ; set the hit chance to 0xFF
.storeAccuracy
	pop hl
	ld [hl], a ; store the hit chance in the move accuracy variable
	ret


BankedStatModifierRatios:
	INCLUDE "data/stat_modifier_ratios.asm"
