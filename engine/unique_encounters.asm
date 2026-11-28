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
	call ChoosePostgameUniqueEncounter
	jr c, .chosen
	call ChooseUniqueEncounter
	ret nc
.chosen
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
	jp z, FindPostgameUniqueLocation
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

; After the first Hall of Fame, one rare themed encounter may replace a
; regular land/surf encounter. A failed roll retains the ordinary pool path.
ChoosePostgameUniqueEncounter:
 push bc
 push de
 push hl
 CheckEvent EVENT_908
 jr z, .unchanged
 ld a, [wCurMap]
 ld b, a
 ld hl, PostgameUniqueEncounters
.scan
 ld a, [hli]
 cp $ff
 jr z, .unchanged
 ld d, a
 ld a, [hli]
 ld e, a
 ld a, d
 cp b
 jr nz, .skip
 ld a, e
 cp c
 jr nz, .skip
 call UniqueEncounterRoll100
 cp 3 ; three percent of encounters in the specified habitat
 jr nc, .unchanged
 ld b, [hl]
 inc hl
 ld c, [hl]
 pop hl
 pop de
 pop af
 scf
 ret
.skip
 inc hl
 inc hl
 jr .scan
.unchanged
 pop hl
 pop de
 pop bc
 and a
 ret

; Reveal these locations in the Pokédex after the same postgame gate.
FindPostgameUniqueLocation:
 CheckEvent EVENT_908
 jr z, .notFound
 ld a, [wd11e]
 ld c, a
 ld hl, PostgameUniqueEncounters
.scan
 ld a, [hli]
 cp $ff
 jr z, .notFound
 ld b, a
 inc hl ; habitat
 inc hl ; level
 ld a, [hli]
 cp c
 jr nz, .scan
 ld a, b
 ld [wBuffer], a
 ld a, $ff
 ld [wBuffer + 1], a
 scf
 ret
.notFound
 and a
 ret

; map, habitat (0 land / 1 surf), level, species
PostgameUniqueEncounters:
 db ROUTE_20, 1, 55, UNIQUE_BLASTOISE_UNIQUE
 db MANSION_3, 0, 50, UNIQUE_GRIMER_POISON
 db ROUTE_12, 0, 50, UNIQUE_IVYSAUR_ERIKA
 db ROUTE_22, 0, 55, UNIQUE_NIDOKING_UNIQUE
 db ROCK_TUNNEL_1, 0, 50, UNIQUE_ONIX_BROCK
 db POWER_PLANT, 0, 55, UNIQUE_RAICHU_UNIQUE
 db ROUTE_15, 0, 50, UNIQUE_TANGELA_ERIKA
 db ROUTE_13, 0, 55, UNIQUE_VENUSAUR_ERIKA
 db $ff
