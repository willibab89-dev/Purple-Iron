SECTION "Critical hit boosts", ROMX, BANK[$33]

; Increase the shared Focus Energy/Dire Hit multiplier, up to x4.
; de = user's BattleStatus2; status 3 is the following byte.
; Carry on success; no carry at the cap. Preserve bc and hl.
RaiseFocusEnergyBoost::
	push hl
	ld h, d
	ld l, e
	inc hl
	ld a, [hl]
	and FOCUS_BOOST_MASK
	cp FOCUS_BOOST_MASK
	jr z, .atMaximum
	ld a, [hl]
	add FOCUS_BOOST_STEP
	ld [hl], a
	dec hl
	set GETTING_PUMPED, [hl]
	pop hl
	scf
	ret
.atMaximum
	pop hl
	and a
	ret
