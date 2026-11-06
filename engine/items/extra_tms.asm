SECTION "Additional TM support", ROMX, BANK[$34]

; Convert a real inventory ID to the unchanged machine move-table ordering.
; Carry distinguishes HM boot text. New items use ordinary TM text/consumption.
DecodeMachineItem:
	ld a, [wcf91]
	sub FIRST_EXTRA_TM
	cp NUM_EXTRA_TMS
	jr nc, .legacy
	add 56
	ld [wd11e], a
	and a
	ret
.legacy
	ld a, [wcf91]
	sub TM_01
	jr nc, .tm
	add 56
	ld [wd11e], a
	scf
	ret
.tm
	inc a
	ld [wd11e], a
	and a
	ret

; Extra bits live in ROM indexed by dex, not in the fixed species header or
; any saved structure. Publish the result in scratch across the bank return.
ExtraTMCompatibility:
	xor a
	ld [wCustomRandomValue], a
	ld a, [wd11e]
	push af
	ld a, [wMoveNum]
	ld b, a
	ld hl, ExtraTMMoves
	ld c, 0
.find
	ld a, [hli]
	cp b
	jr z, .found
	inc c
	ld a, c
	cp NUM_EXTRA_TMS
	jr c, .find
	jr .done
.found
	ld a, c
	ld [wCustomStat], a
	ld a, [wMonHIndex]
	ld [wd11e], a
	callab IndexToPokedex
	ld a, [wd11e]
	and a
	jr z, .done
	cp NUM_POKEMON + 1
	jr nc, .done
	dec a
	ld c, a
	ld b, 0
	sla c
	rl b
	ld hl, ExtraTMCompatibilityTable
	add hl, bc
	ld a, [wCustomStat]
	cp 8
	jr c, .byte
	inc hl
	sub 8
.byte
	ld c, 1
	and a
	jr z, .mask
.shift
	sla c
	dec a
	jr nz, .shift
.mask
	ld a, [hl]
	and c
	ld [wCustomRandomValue], a
.done
	pop af
	ld [wd11e], a
	ret

ExtraTMMoves:
	db ROOST,FACADE,BRINE,VENOSHOCK,AERIAL_ACE
	db BULK_UP,ROCK_TOMB,WILL_O_WISP,SCALD,CURSE
	db LEECH_LIFE,POISON_TAIL,AGILITY
INCLUDE "data/extra_tm_compatibility.asm"

INCLUDE "text/tmhm_names.asm"
