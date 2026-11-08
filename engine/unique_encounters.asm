SECTION "Unique encounter rules", ROMX, BANK[$33]

; One roll after ordinary/Safari selection covers both variants and route
; rares. Each rule retains its own rate where several habitats overlap.
TryUniqueWildEncounter:
	ld c, 0 ; land/cave
	aCoord 9, 9
	cp $14
	jr nz, .select
	inc c ; surfing
.select
	call ChooseUniqueEncounter
	ret nc
	ld a, b
	ld [wCurEnemyLVL], a
	ld a, c
	ld [wcf91], a
	ld [wEnemyMonSpecies2], a
	ret

; Called only after a successful bite, with the original rod item still in
; wcf91 and the normal level/species already stored by RodResponse.
TryUniqueFishingEncounter:
	ld a, [wcf91]
	cp GOOD_ROD
	ld c, 2
	jr z, .select
	cp SUPER_ROD
	ret nz ; Old Rod retains its Magikarp behavior.
	inc c
.select
	call ChooseUniqueEncounter
	ret nc
	ld a, b
	ld [wCurEnemyLVL], a
	ld a, c
	ld [wCurOpponent], a
	ret

; Input c = habitat (0 land, 1 surf, 2 Good Rod, 3 Super Rod).
; Carry: unique result in bc = level/species. Otherwise preserve bc.
ChooseUniqueEncounter:
	push bc
	push de
	push hl
	ld a, [wCurMap]
	ld b, a
	ld hl, UniqueEncounterPools
.scan
	ld a, [hli]
	cp $ff
	jr z, .unchanged
	ld d, a ; map
	ld a, [hli]
	ld e, a ; habitat
	ld a, [hli]
	push af ; pool size
	ld a, d
	cp b
	jr nz, .skip
	ld a, e
	cp c
	jr nz, .skip
	pop af
	ld c, a
	call UniqueEncounterRoll100
	cp c
	jr nc, .unchanged
	add a
	ld e, a
	ld d, 0
	add hl, de
	ld b, [hl]
	inc hl
	ld c, [hl]
	pop hl
	pop de
	pop af ; discard original bc
	scf
	ret
.skip
	pop af
	add a
	ld e, a
	ld d, 0
	add hl, de
	jr .scan
.unchanged
	pop hl
	pop de
	pop bc
	and a
	ret

; Reject 200..255, then map 0..199 evenly to 0..99. No modulo bias.
UniqueEncounterRoll100:
.retry
	call Random
	cp 200
	jr nc, .retry
	cp 100
	ret c
	sub 100
	ret

; Rule-based species use a generated union of pool and ordinary habitats.
; Carry means handled; other species use the original scanner.
FindUniqueWildLocations:
	ld a, [wd11e]
	ld c, a
	ld hl, UniqueEncounterLocations
.scan
	ld a, [hli]
	cp $ff
	jr z, .notFound
	cp c
	ld b, [hl]
	inc hl
	jr z, .found
	ld e, b
	ld d, 0
	add hl, de
	jr .scan
.found
	ld de, wBuffer
.copy
	ld a, [hli]
	ld [de], a
	inc de
	dec b
	jr nz, .copy
	ld a, $ff
	ld [de], a
	scf
	ret
.notFound
	and a
	ret

INCLUDE "data/unique_encounters.asm"
