; tests if mon [wcf91] can learn move [wMoveNum]
CanLearnTM:
	ld a, [wcf91]
	ld [wd0b5], a
	call GetMonHeader
	ld hl, wMonHLearnset
	push hl
	ld a, [wMoveNum]
	ld b, a
	ld c, $0
	ld hl, TechnicalMachines
.findTMloop
	ld a, [hli]
	cp b
	jr z, .TMfoundLoop
	inc c
	ld a, c
	cp 65
	jr c, .findTMloop
	pop hl
	ld c, 0
	ret
.TMfoundLoop
	pop hl
	ld a, c
	cp 55
	jr c, .ordinary
	callab ExtraTMCompatibility
	ld a, [wCustomRandomValue]
	ld c, a
	ret
.ordinary
	ld b, FLAG_TEST
	predef_jump FlagActionPredef

; converts TM/HM number in wd11e into move number
; HMs occupy 51–55; added TMs use internal entries 56–65.
TMToMove:
	ld a, [wd11e]
	dec a
	ld hl, TechnicalMachines
	ld b, $0
	ld c, a
	add hl, bc
	ld a, [hl]
	ld [wd11e], a
	ret

INCLUDE "data/tms.asm"
