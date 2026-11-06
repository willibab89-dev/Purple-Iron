;Convert a value from the 1st party pkmn into a normalized BCD-value score stored in wcd6d
;takes a number loaded into wcd6d to determine value:
;	1 is catch rate
;	2 is level
;	default is DVs
Mon1BCDScore:
	push de
	push hl
	push bc
	ld a, [wcd6d]

	cp 2
	jr nz, .next1
	ld a, [wPartyMon1Level]
	ld b, a
	srl a
	add b
	add b
	jr .next

.next1
	cp 1
	jr nz, .default
	ld a, [wPartyMon1CatchRate]
	ld b, a
	ld a, $FF
	sub b
	jr .next

.default
	ld a, [wPartyMon1DVs]	;load first two nybbles of DVs
	srl a	;shift all bits to the right one time
	and $F7	; clear the highest bit of the low nybble in case the high nybble overflowed into the low nybble
	ld b, a
	ld a, [wPartyMon1DVs + 1]	;load second two nybbles of DVs
	srl a	;shift all bits to the right one time
	and $F7	; clear the highest bit of the low nybble in case the high nybble overflowed into the low nybble
	add b

.next
	ld b, a
	xor a
	ld [hCoins], a
	ld [hCoins + 1], a
	ld [wcd6d], a
	ld [wcd6d + 1], a
	ld [wcd6d + 2], a
	
	ld a, b
	ld hl, hCoins
	call Hex2BCD
	
	ld de, wcd6d + 1
	ld hl, hCoins + 1
	ld c, $2
	predef AddBCDPredef	;add value in hl location to value in de location
	ld de, wcd6d + 1
	ld hl, hCoins + 1
	ld c, $2
	predef AddBCDPredef	;add value in hl location to value in de location

	xor a
	ld [hCoins], a
	ld [hCoins + 1], a

	pop bc
	pop hl
	pop de
	ret


	
;play cry if the 1st pokemon has payday in its move set
LuckySlotDetect:
	push hl
	ld b, NUM_MOVES + 1
	ld hl, wPartyMon1Moves
.loop
	dec b
	jr z, .return
	ld a, [hli]
	cp PAY_DAY
	jr nz, .loop
	ld a, [wPartyMon1Species]
	call PlayCry
.return
	pop hl
	ret
	

;this function makes glitched pokemon names stable by restoring them back to the normal nickname format
;this is called from GetPartyMonName
FixNickNames:
	ld c, 1
	ld h, d
	ld l, e
	ld a, [hl]
	cp $50
	jr z, .notvalid
.loop
	ld a, c
	cp NAME_LENGTH
	jr z, .finish
	ld a, [hl]
	
	cp $50
	jr z, .eol
	
	cp $7F
	jr c, .notvalid
	
	cp $F6
	jr nc, .notvalid
	
	cp $E1
	jr nc, .valid
	
	cp $C0
	jr c, .valid

.notvalid
	ld [hl], $F1
.valid
	inc hl
	inc c
	jr .loop

.finish
	ld a, [hl]
	cp $50
	ret z
	ld [hl], $50
	ret
	
.eol
	inc c
	inc hl
	ld a, c
	cp NAME_LENGTH
	jr z, .finish
	ld [hl], $50
	jr .eol
	
	
Hex2BCD:	;convert number in A to BCD in HL
	ld [H_DIVIDEND + 3], a
	xor a
	ld [H_DIVIDEND], a
	ld [H_DIVIDEND + 1], a
	ld [H_DIVIDEND + 2], a
	ld a, 100
	ld [H_DIVISOR], a
	ld b, $4
	call Divide
	ld a, [H_QUOTIENT + 3]
	ld [hli], a
	ld a, [H_REMAINDER]
	ld [H_DIVIDEND + 3], a
	ld a, 10
	ld [H_DIVISOR], a
	ld b, $4
	call Divide
	ld a, [H_QUOTIENT + 3]
	swap a
	ld b, a
	ld a, [H_REMAINDER]
	add b
	ld [hl], a
	ret


;returns z if not owned and nz if owned
IsEnemyMonOwned:
	push de
	ld a, [wEnemyMonSpecies]
	ld [wd11e], a
	predef IndexToPokedex
	callba IsPokemonOwnedBitSet
	pop de
	ret
	
;play an enemy mon's cry if it's already owned in the dex
CryIfOwned:
	call IsEnemyMonOwned
	ret z	;return if not owned
	ld a, [wEnemyMonSpecies]
	call PlayCry
	ret
	

; This function called to store PKMN Levels. Usually at the beginning of battle.
StorePKMNLevels:
	push hl
	push de
	ld a, [wPartyCount]	;1 to 6
	ld b, a	;use b for countdown
	ld hl, wPartyMon1Level
	ld de, wStartBattleLevels
.loopStorePKMNLevels
	ld a, [hl]
	ld [de], a	
	dec b
	jr z, .doneStorePKMNLevels
	push bc
	ld bc, wPartyMon2 - wPartyMon1
	add hl, bc
	inc de
	pop bc
	jr .loopStorePKMNLevels
.doneStorePKMNLevels
	pop de
	pop hl
	ret


;determine if the mon should have a gender symbol
;mons that are genderless or a single gender do not get a symbol
;takes a pokemon index in d
;takes its atk dv in e
;symbol is returned in d --> ;$F5 for female and $EF for male
DetermineMonGender:
	ld a, d
	cp MILTANK
	jr nz, .notMiltank
	ld d, $F5
	ret
.notMiltank
	cp MAREANIE
	jr z, .newHalf
	cp TOXAPEX
	jr z, .newHalf
	cp SABLEYE
	jr nz, .originalSpecies
.newHalf
	ld a, e
	cp 8
	ld d, $EF
	ret nc
	ld d, $F5
	ret
.originalSpecies
	ld a, d
	call UniqueSpeciesToOriginal
	ld d, a
	xor a
	ld b, a
	ld hl, ListByGenderRatio
.loop
	ld a, [hli]
	and a
	jr z, .nosymbol
	cp d
	jr z, .foundmon
	inc b
	jr .loop
.foundmon
	ld a, b
	call GetGenderRatioTarget
	ld a, e
	cp b
.male
	ld d, $EF
	ret nc
.female
	ld d, $F5
	ret c
.nosymbol
	ld d, $00
	ret


;ResetRandomHiddenItem:
;	;get a random hidden item flag byte
;	call Random
;	and $0F
;	ld hl, wObtainedHiddenItemsFlags
;	ld b, 0
;	ld c, a
;	add hl, bc
;	;get a random bit
;	call Random
;	and $07
;	ld b, a
;	;make sure it's not the surf board
;	call .checksurfboard
;	ret c
;	;clear the flag
;	inc b
;	ld a, %01111111
;.loop
;	rlca
;	dec b
;	jr nz, .loop
;	ld b, a
;	ld a, [hl]
;	and b
;	;all done
;	ret
;.checksurfboard
;do not reset getting the surf board
;	ld a, c
;	cp 6
;	jr nz, .returnNC
;	ld a, b
;	cp 6
;	jr nz, .returnNC
;	scf	;set the carry flag
;	ret
;.returnNC
;	and a	;clear the carry flag
;	ret

;ResetRandomShowItem:
;	call GetRandHideShowItem
;	ld [wMissableObjectIndex], a
;	predef ShowObject 
;	ret
;GetRandHideShowItem:
;	ld hl, ListGameItems
;	call Random
;	ld b, a
;.loop
;	ld a, [hli]
;	and a
;	jr z, .reloadHL
;	ld c, a
;	ld a, b
;	sub 1
;	ld b, a
;	ld a, c
;	ret c
;	jr .loop
;.reloadHL
;	ld hl, ListGameItems
;	jr .loop

;ResetRandItemsOnInterval:
;	call ResetRandomShowItem
;	call ResetRandomHiddenItem
;	ret

UniqueSpeciesSourceIDs:
	db UNIQUE_BLASTOISE_UNIQUE, BLASTOISE
	db UNIQUE_BULBASAUR_UNIQUE, BULBASAUR
	db UNIQUE_CHANSEY_UNIQUE, CHANSEY
	db UNIQUE_CHARMANDER_UNIQUE, CHARMANDER
	db UNIQUE_DITTO_HAPPY, DITTO
	db UNIQUE_GEODUDE_FIGHTING, GEODUDE
	db UNIQUE_GOLDEEN_FIGHTING, GOLDEEN
	db UNIQUE_GRIMER_POISON, GRIMER
	db UNIQUE_IVYSAUR_ERIKA, IVYSAUR
	db UNIQUE_KAKUNA_ROCK_TYPE, KAKUNA
	db UNIQUE_MAROWAK_UNIQUE, MAROWAK
	db UNIQUE_NIDOKING_UNIQUE, NIDOKING
	db UNIQUE_NIDOKING_UNIQUE2, NIDOKING
	db UNIQUE_NIDORANM_UNIQUE, NIDORAN_M
	db UNIQUE_OMANYTE_UNIQUE, OMANYTE
	db UNIQUE_ONIX_BROCK, ONIX
	db UNIQUE_RAICHU_UNIQUE, RAICHU
	db UNIQUE_SQUIRTLE_UNIQUE, SQUIRTLE
	db UNIQUE_TANGELA_ERIKA, TANGELA
	db UNIQUE_TENTACOOL_BIG, TENTACOOL
	db UNIQUE_VENUSAUR_ERIKA, VENUSAUR

; Return the source species in a, preserving other registers.
UniqueSpeciesToOriginal:
 push bc
 push hl
 ld b, a
 ld hl, UniqueSpeciesSourceIDs
 ld c, 21
.loop
 ld a, [hli]
 cp b
 jr z, .found
 inc hl
 dec c
 jr nz, .loop
 ld a, b
 jr .done
.found
 ld a, [hl]
.done
 pop hl
 pop bc
 ret
