SECTION "Resourceful ability and PP", ROMX, BANK[$35]

 ; Return nonzero only for the saved Resourceful slot of this family.
AbilityResourcefulCheckMon:
	ld a, [hl]
	cp MEOWTH
	jr z, .species
	cp PERSIAN
	jr nz, .no
.species
	ld bc, 5
	add hl, bc
	ld a, [hli]
	and $e0
	cp 3 << 5
	jr nz, .no
	ld a, [hl]
	and NATURE_FORMAT_MASK
	cp NATURE_FORMAT_TAG
	jr nz, .no
	ld a, 1
	and a
	ret
.no
	xor a
	ret

; HL = saved mon. Add the bonus to its existing moves' current PP.
AbilityResourcefulBoostMon:
	push hl
	call AbilityResourcefulCheckMon
	pop hl
	ret z
	push hl
	ld bc, wPartyMon1Moves - wPartyMon1
	add hl, bc
	pop de
	push hl
	ld h, d
	ld l, e
	ld bc, wPartyMon1PP - wPartyMon1
	add hl, bc
	ld d, h
	ld e, l
	pop hl
AbilityResourcefulBoostMoves:
	ld b, NUM_MOVES
.loop
	ld a, [hli]
	and a
	jr z, .next
	push bc
	push hl
	ld h, d
	ld l, e
	call AbilityResourcefulAddOne
	pop hl
	pop bc
.next
	inc de
	dec b
	jr nz, .loop
	ret

; Preserve the two PP-Up bits; the six-bit count cannot exceed 63.
AbilityResourcefulAddOne:
	ld a, [hl]
	ld b, a
	and $3f
	add 5
	cp 64
	jr c, .fits
	ld a, 63
.fits
	ld c, a
	ld a, b
	and $c0
	or c
	ld [hl], a
	ret

AbilityResourcefulNewMon:
	ld a, [hNewPartyLength]
	dec a
	ld hl, wPartyMon1
	ld bc, wPartyMon2 - wPartyMon1
	ld a, [wMonDataLocation]
	and $f
	jr z, .index
	ld hl, wEnemyMon1
	ld bc, wEnemyMon2 - wEnemyMon1
.index
	ld a, [hNewPartyLength]
	dec a
	call AddNTimes
	jp AbilityResourcefulBoostMon

AbilityResourcefulHeal:
	ld a, [wWhichPokemon]
	ld hl, wPartyMon1
	ld bc, wPartyMon2 - wPartyMon1
	call AddNTimes
	jp AbilityResourcefulBoostMon

; Called with HL pointing to the freshly written PP byte.
AbilityResourcefulLearnedPP:
	ld a, [wNatureInputHL]
	ld h, a
	ld a, [wNatureInputHL + 1]
	ld l, a
	push hl
	ld a, [wWhichPokemon]
	ld hl, wPartyMon1
	ld bc, wPartyMon2 - wPartyMon1
	call AddNTimes
	call AbilityResourcefulCheckMon
	pop hl
	ret z
	jp AbilityResourcefulAddOne
AbilityResourcefulDaycarePP:
	ld a, [wNatureInputHL]
	ld h, a
	ld a, [wNatureInputHL + 1]
	ld l, a
	push hl
	ld a, [wPartyCount]
	and a
	jr z, .none
	dec a
	ld hl, wPartyMon1
	ld bc, wPartyMon2 - wPartyMon1
	call AddNTimes
	call AbilityResourcefulCheckMon
	pop hl
	ret z
	jp AbilityResourcefulAddOne
.none
	pop hl
	ret

; LoadMovePPs returns HL just beyond its move array. Only enemy battle data
; uses this array; other callers use the unmodified base PP table.
AbilityResourcefulEnemyLoadedPP:
	ld a, [wNatureInputHL]
	ld h, a
	ld a, [wNatureInputHL + 1]
	ld l, a
	ld a, h
	cp HIGH(wEnemyMonMoves + NUM_MOVES)
	ret nz
	ld a, l
	cp LOW(wEnemyMonMoves + NUM_MOVES)
	ret nz
	ld a, [wActiveAbilities + 1]
	cp AB_RESOURCEFUL
	ret nz
	ld hl, wEnemyMonMoves
	ld de, wEnemyMonPP
	jp AbilityResourcefulBoostMoves

AbilityResourcefulSelected:
	ld a, [wMonDataLocation]
	and a
	jr z, .party
	cp 1
	jr z, .enemy
	cp 2
	jr z, .box
	cp 3
	jr z, .daycare
	cp 4
	jr nz, .no
	ld a, [wPlayerBattleStatus3]
	bit TRANSFORMED, a
	jr nz, .no
	ld a, [wPlayerMonNumber]
	ld hl, wPartyMon1
	ld bc, wPartyMon2 - wPartyMon1
	jr .indexed
.party
	ld hl, wPartyMon1
	ld bc, wPartyMon2 - wPartyMon1
	jr .selectedIndex
.enemy
	ld hl, wEnemyMon1
	ld bc, wEnemyMon2 - wEnemyMon1
	jr .selectedIndex
.box
	ld hl, wBoxMon1
	ld bc, wBoxMon2 - wBoxMon1
.selectedIndex
	ld a, [wWhichPokemon]
.indexed
	call AddNTimes
	jp AbilityResourcefulCheckMon
.daycare
	ld hl, wDayCareMon
	jp AbilityResourcefulCheckMon
.no
	xor a
	ret
AbilityResourcefulMaxPP:
	call AbilityResourcefulSelected
	ret z
	ld a, [wMaxPP]
	add 5
	cp 64
	jr c, .store
	ld a, 63
.store
	ld [wMaxPP], a
	ret

 ; Adjust current PP by the actual maximum change when a capsule enters or
; leaves Resourceful. Preserve spent PP and all packed PP-Up bits.
AbilityResourcefulCapsuleAdjust:
	ld a, [wNatureMonPtr]
	ld h, a
	ld a, [wNatureMonPtr + 1]
	ld l, a
	ld a, [hl]
	cp MEOWTH
	jr z, .family
	cp PERSIAN
	ret nz
.family
	ld a, [wNatureResult]
	cp 3
	jr nz, .maybeGain
	ld a, [wNatureSlot]
	cp 3
	ret z
	xor a ; losing
	jr .mode
.maybeGain
	ld a, [wNatureSlot]
	cp 3
	ret nz
	ld a, 1 ; gaining
.mode
	ld [wAbilityTemp], a
	ld hl, wPartyMon1
	ld d, 0
.find
	ld a, [wNatureMonPtr]
	cp h
	jr nz, .next
	ld a, [wNatureMonPtr + 1]
	cp l
	jr z, .found
.next
	ld bc, wPartyMon2 - wPartyMon1
	add hl, bc
	inc d
	ld a, d
	cp 6
	jr c, .find
	ret
.found
	ld a, d
	ld [wAbilityCheckResult], a
	ld bc, 5
	add hl, bc
	ld a, [hl]
	ld [wAbilityTemp + 1], a
	and $1f
	or 1 << 5 ; temporarily query the ordinary maximum
	ld [hl], a
	ld a, [wWhichPokemon]
	push af
	ld a, [wMonDataLocation]
	push af
	ld a, [wCurrentMenuItem]
	push af
	ld a, [wUsingPPUp]
	push af
	ld a, [wMaxPP]
	push af
	xor a
	ld [wMonDataLocation], a
	ld [wCurrentMenuItem], a
	ld a, [wAbilityCheckResult]
	ld [wWhichPokemon], a
.moveLoop
	ld a, [wWhichPokemon]
	ld hl, wPartyMon1Moves
	ld bc, wPartyMon2 - wPartyMon1
	call AddNTimes
	ld a, [wCurrentMenuItem]
	ld c, a
	ld b, 0
	add hl, bc
	ld a, [hl]
	and a
	jr z, .nextMove
	callab GetMaxPP
	ld a, [wMaxPP]
	ld b, a
	ld a, 63
	sub b
	cp 5
	jr c, .delta
	ld a, 5
.delta
	ld d, a
	ld a, [wWhichPokemon]
	ld hl, wPartyMon1PP
	ld bc, wPartyMon2 - wPartyMon1
	call AddNTimes
	ld a, [wCurrentMenuItem]
	ld c, a
	ld b, 0
	add hl, bc
	ld a, [hl]
	ld b, a
	and $3f
	ld c, a
	ld a, [wAbilityTemp]
	and a
	ld a, c
	jr z, .remove
	add d
	cp 64
	jr c, .store
	ld a, 63
	jr .store
.remove
	sub d
	jr nc, .store
	xor a
.store
	ld c, a
	ld a, b
	and $c0
	or c
	ld [hl], a
.nextMove
	ld hl, wCurrentMenuItem
	inc [hl]
	ld a, [hl]
	cp NUM_MOVES
	jr c, .moveLoop
	pop af
	ld [wMaxPP], a
	pop af
	ld [wUsingPPUp], a
	pop af
	ld [wCurrentMenuItem], a
	pop af
	ld [wMonDataLocation], a
	pop af
	ld [wWhichPokemon], a
	ld a, [wNatureMonPtr]
	ld h, a
	ld a, [wNatureMonPtr + 1]
	ld l, a
	ld bc, 5
	add hl, bc
	ld a, [wAbilityTemp + 1]
	ld [hl], a
	ret

