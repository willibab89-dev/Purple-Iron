SECTION "Expanded Pokedex save compatibility", ROMX, BANK[$3d]

; The original save keeps two 23-byte dex fields. Four previously unused
; save bytes hold the added flag bytes; a three-byte marker distinguishes old
; saves. SRAM offsets, checksums and total saved data size stay unchanged.
LEGACY_DEX_BYTES EQU 23
DEX_EXTRA_COUNT EQU 2
DEX_SAVE_MARKER_1 EQU $4b
DEX_SAVE_MARKER_2 EQU $32
DEX_SAVE_MARKER_3 EQU $58
sDexExtension EQUS "sMainData + (wPokedexExtensionPadding - wMainDataStart) - 4"

LoadExpandedPokedex:
 ld hl, sMainData
 ld de, wPokedexOwned
 ld bc, LEGACY_DEX_BYTES
 call CopyData
 ld hl, sMainData + LEGACY_DEX_BYTES
 ld de, wPokedexSeen
 ld bc, LEGACY_DEX_BYTES
 call CopyData
 xor a
 ld [wPokedexOwned + LEGACY_DEX_BYTES], a
 ld [wPokedexOwned + LEGACY_DEX_BYTES + 1], a
 ld [wPokedexSeen + LEGACY_DEX_BYTES], a
 ld [wPokedexSeen + LEGACY_DEX_BYTES + 1], a
 ld hl, sDexExtension
 ld a, [hli]
 cp DEX_SAVE_MARKER_1
 ret nz
 ld a, [hli]
 cp DEX_SAVE_MARKER_2
 ret nz
 ld a, [hli]
 cp DEX_SAVE_MARKER_3
 ret nz
 ld a, [hli]
 ld [wPokedexOwned + LEGACY_DEX_BYTES], a
 ld a, [hli]
 ld [wPokedexOwned + LEGACY_DEX_BYTES + 1], a
 ld a, [hli]
 ld [wPokedexSeen + LEGACY_DEX_BYTES], a
 ld a, [hl]
 ld [wPokedexSeen + LEGACY_DEX_BYTES + 1], a
 ret

SaveExpandedPokedex:
 ld hl, wPokedexOwned
 ld de, sMainData
 ld bc, LEGACY_DEX_BYTES
 call CopyData
 ld hl, wPokedexSeen
 ld de, sMainData + LEGACY_DEX_BYTES
 ld bc, LEGACY_DEX_BYTES
 call CopyData
 ld hl, sDexExtension
 ld a, DEX_SAVE_MARKER_1
 ld [hli], a
 ld a, DEX_SAVE_MARKER_2
 ld [hli], a
 ld a, DEX_SAVE_MARKER_3
 ld [hli], a
 ld a, [wPokedexOwned + LEGACY_DEX_BYTES]
 ld [hli], a
 ld a, [wPokedexOwned + LEGACY_DEX_BYTES + 1]
 ld [hli], a
 ld a, [wPokedexSeen + LEGACY_DEX_BYTES]
 ld [hli], a
 ld a, [wPokedexSeen + LEGACY_DEX_BYTES + 1]
 ld [hl], a
 ret

LoadExpandedMainData:
 call LoadExpandedPokedex
 ld hl, sMainData + LEGACY_DEX_BYTES * 2
 ld de, wPokedexSeenEnd
 ld bc, wPokedexExtensionPadding - wPokedexSeenEnd
 call CopyData
 ld hl, sMainData + (wPlayTimeHours - wMainDataStart)
 ld de, wPlayTimeHours
 ld bc, wMainDataEnd - wPlayTimeHours
 jp CopyData

SaveExpandedMainData:
 call SaveExpandedPokedex
 ld hl, wPokedexSeenEnd
 ld de, sMainData + LEGACY_DEX_BYTES * 2
 ld bc, wPokedexExtensionPadding - wPokedexSeenEnd
 call CopyData
 ld hl, wPlayTimeHours
 ld de, sMainData + (wPlayTimeHours - wMainDataStart)
 ld bc, wMainDataEnd - wPlayTimeHours
 jp CopyData
