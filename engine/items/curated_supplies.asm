SECTION "Curated supplies", ROMX, BANK[$3d]

UseCuratedSupplyItem::
	ld a, [wIsInBattle]
	and a
	jp nz, .notTime
	ld a, [wPartyCount]
	and a
	jp z, .noEffect
	ld a, [wcf91]
	cp FIRST_AID
	jp z, .firstAid
; Native party selection replaces the bag's wWhichPokemon and item name.
; Save both on the stack, exactly as the original medicine handler does.
	ld a, [wWhichPokemon]
	push af
	ld a, [wcf91]
	push af
	ld a, USE_ITEM_PARTY_MENU
	ld [wPartyMenuTypeOrMessageID], a
	ld a, $ff
	ld [wUpdateSpritesEnabled], a
	call DisplayPartyMenu
	jr c, .cancel
	ld hl, wPartyMons
	ld bc, wPartyMon2 - wPartyMon1
	ld a, [wWhichPokemon]
	call AddNTimes
	ld a, h
	ld [wNatureMonPtr], a
	ld a, l
	ld [wNatureMonPtr + 1], a
	pop af
	ld [wcf91], a
	pop af
	ld [wWhichPokemon], a
	ld a, [wcf91]
	cp NATURE_CAPSULE
	jr z, .nature
	abilitycall AbilityCapsuleCheck
	ld a, [wAbilityID]
	and a
	jp z, .noEffect
	abilitycall AbilityCapsuleApply
	ld hl, .abilityText
	jr .success
.nature
	abilitycall NatureCapsuleApply
	ld hl, .natureText
	jr .success
.cancel
	pop af
	ld [wcf91], a
	pop af
	ld [wWhichPokemon], a
	xor a
	ld [wActionResultOrTookBattleTurn], a
	ret
.firstAid
	call FirstAidHealParty
	ld a, [wSupplyChanged]
	and a
	jr z, .noEffect
	ld hl, .firstAidText
.success
	call PrintText
	jpab RemoveUsedItem
.noEffect
	jpab ItemUseNoEffect
.notTime
	jpab ItemUseNotTime
.abilityText
	text "Its ABILITY"
	line "changed!"
	prompt
.natureText
	text "Its NATURE"
	line "changed!"
	prompt
.firstAidText
	text "The party"
	line "recovered HP!"
	prompt

; Each living member gets floor(maximum HP / 2), at least 1 HP.
; Status, PP and fainted members are untouched; one item heals the whole party.
FirstAidHealParty::
	xor a
	ld [wSupplyChanged], a
	ld hl, wPartyMon1
	ld a, [wPartyCount]
	and a
	ret z
	ld b, a
.loop
	push bc
	push hl
	inc hl
	ld a, [hli]
	ld d, a
	ld a, [hl]
	ld e, a
	or d
	jr z, .next
	ld bc, wPartyMon1MaxHP - (wPartyMon1HP + 1)
	add hl, bc
	ld a, [hli]
	ld b, a
	ld c, [hl]
; BC = maximum, DE = current; skip full health.
	ld a, d
	cp b
	jr c, .heal
	jr nz, .next
	ld a, e
	cp c
	jr nc, .next
.heal
	push bc
	srl b
	rr c
	ld a, b
	or c
	jr nz, .add
	inc c
.add
	ld a, e
	add c
	ld e, a
	ld a, d
	adc b
	ld d, a
	pop bc
	jr c, .cap
	ld a, d
	cp b
	jr c, .store
	jr nz, .cap
	ld a, e
	cp c
	jr c, .store
.cap
	ld d, b
	ld e, c
.store
	pop hl
	push hl
	inc hl
	ld [hl], d
	inc hl
	ld [hl], e
	ld a, 1
	ld [wSupplyChanged], a
.next
	pop hl
	ld bc, wPartyMon2 - wPartyMon1
	add hl, bc
	pop bc
	dec b
	jr nz, .loop
	ret

INCLUDE "engine/items/curated_loot.asm"
INCLUDE "data/curated_loot.asm"
