SECTION "Imported sprite routing", ROMX, BANK[$34]
RouteImportedSprite:
	ld a, [wSpriteInputPtr]
	cp 13
	jr nz, .legacy
	call ImportedBackPointer
	ld a, [hli]
	and a
	jr z, .legacy
	push af
	ld a, [hli]
	ld [wSpriteInputPtr], a
	ld a, [hl]
	ld [wSpriteInputPtr + 1], a
	pop af
	jp UncompressSpriteData
.legacy
	ld a, [wSpriteInputPtr]
	ld l, a
	ld h, 0
	ld bc, wMonHeader
	add hl, bc
	ld a, [hli]
	ld [wSpriteInputPtr], a    ; fetch sprite input pointer
	ld a, [hl]
	ld [wSpriteInputPtr+1], a
;joenote - expanding this to use 7 rom banks to fit the spaceworld back sprites if desired
; define (by index number) the bank that a pokemon's image is in
	ld a, [wcf91] ; sprite identity
	ld b, a
	cp MAREANIE
	jr z, .newSpecies
	cp TOXAPEX
	jr z, .newSpecies
	cp MILTANK
	jr z, .newSpecies
	cp SABLEYE
	jr z, .newSpecies
	jr .oldSpecies
.newSpecies
	ld a, BANK(MareaniePicFront)
	jp UncompressSpriteData
.oldSpecies
	ld hl, UniqueSpeciesSpriteIDs
	ld c, 21
.uniqueSpriteLoop
	ld a, [hli]
	cp b
	ld a, BANK(Unique1PicFront)
	jr z, .GotBank
	dec c
	jr nz, .uniqueSpriteLoop
	ld a, b
	cp MEW
	ld a, BANK(MewPicFront)
	jr z, .GotBank
	ld a, b
	cp SHELLDER + 1
	ld a, BANK(ShellderPicFront)
	jr c, .GotBank
	ld a, b
	cp DROWZEE + 1
	ld a, BANK(DrowzeePicFront)
	jr c, .GotBank
	ld a, b
	cp NINETALES + 1
	ld a, BANK(NinetalesPicFront)
	jr c, .GotBank
	ld a, b
	cp KAKUNA + 1
	ld a, BANK(KakunaPicFront)
	jr c, .GotBank
	ld a, b
	cp CLEFABLE + 1
	ld a, BANK(ClefablePicFront)
	jr c, .GotBank
	ld a, b
	cp PORYGON + 1
	ld a, BANK(PorygonPicFront)
	jr c, .GotBank
	ld a, BANK(VictreebelPicFront)
.GotBank
	jp UncompressSpriteData

UniqueSpeciesSpriteIDs:
	db UNIQUE_BLASTOISE_UNIQUE, UNIQUE_BULBASAUR_UNIQUE, UNIQUE_CHANSEY_UNIQUE, UNIQUE_CHARMANDER_UNIQUE, UNIQUE_DITTO_HAPPY, UNIQUE_GEODUDE_FIGHTING, UNIQUE_GOLDEEN_FIGHTING, UNIQUE_GRIMER_POISON, UNIQUE_IVYSAUR_ERIKA, UNIQUE_KAKUNA_ROCK_TYPE, UNIQUE_MAROWAK_UNIQUE, UNIQUE_NIDOKING_UNIQUE, UNIQUE_NIDOKING_UNIQUE2, UNIQUE_NIDORANM_UNIQUE, UNIQUE_OMANYTE_UNIQUE, UNIQUE_ONIX_BROCK, UNIQUE_RAICHU_UNIQUE, UNIQUE_SQUIRTLE_UNIQUE, UNIQUE_TANGELA_ERIKA, UNIQUE_TENTACOOL_BIG, UNIQUE_VENUSAUR_ERIKA


ImportedBackPointer:
	ld a, [wcf91]
	dec a
	ld c, a
	ld b, 0
	ld hl, CustomBackStreams
	add hl, bc
	add hl, bc
	add hl, bc
	ret
PrepareImportedBack:
	call ImportedBackPointer
	ld a, [hl]
	and a
	jp z, .legacy
	ld a, 0
	ld [$4000], a
	ld hl, sSpriteBuffer1
	ld de, sSpriteBuffer0
	ld bc, SPRITEBUFFERSIZE
	call CopyData
	ld hl, sSpriteBuffer2
	ld de, sSpriteBuffer1
	ld bc, SPRITEBUFFERSIZE
	jp CopyData
.legacy
	jpab ScaleSpriteByTwo
INCLUDE "data/imported_back_streams.asm"
