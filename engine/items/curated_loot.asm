; Input/output wLootItem. No RNG or saved-state writes. Sprite ID is stable
; while a pickup remains uncollected, including failed bag-full attempts.
SelectCuratedLoot::
	ld a, [wPlayerID]
	ld b, a
	ld a, [wPlayerID + 1]
	rlca
	xor b
	ld b, a
	ld a, [wCurMap]
	rlca
	rlca
	rlca
	xor b
	ld b, a
	ld a, [hSpriteIndexOrTextID]
	add a
	add b
	xor $a7
	ld [wLootHash], a
	ld a, [wCurMap]
	ld b, a
	ld hl, CuratedLateMaps
.map
	ld a, [hli]
	cp $ff
	jr z, .regular
	cp b
	jr nz, .map
	ld a, [wLootItem]
	ld b, a
	ld hl, CuratedPremiumItems
.premium
	ld a, [hli]
	and a
	jr z, .regular
	cp b
	jr nz, .premium
	ld a, [wLootHash]
	and 15
	cp 10
	ret c ; original, 10/16
	ld b, FIRST_AID
	cp 14
	jr c, .store
	ld b, NATURE_CAPSULE
	jr z, .store
	ld b, ABILITY_CAPSULE
.store
	ld a, b
	ld [wLootItem], a
	ret
.regular
	ld a, [wLootItem]
	ld b, a
	ld hl, CuratedLootPools
.find
	ld a, [hli]
	and a
	ret z ; unlisted originals always fixed
	cp b
	jr z, .found
	inc hl
	inc hl
	jr .find
.found
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld b, [hl]
	inc hl
	ld a, [wLootHash]
.modulo
	cp b
	jr c, .choose
	sub b
	jr .modulo
.choose
	ld e, a
	ld d, 0
	add hl, de
	ld a, [hl]
	ld [wLootItem], a
	ret
