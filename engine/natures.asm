SECTION "Nature engine", ROMX, BANK[$3b]

NatureInputHL:
	ld a, [wNatureInputHL]
	ld h, a
	ld a, [wNatureInputHL + 1]
	ld l, a
	ret
NatureInputDE:
	ld a, [wNatureInputDE]
	ld h, a
	ld a, [wNatureInputDE + 1]
	ld l, a
	ret
NatureRoll:
	call Random
	cp NUM_NATURES
	jr nc, NatureRoll
	ld [wNatureID], a
	ret
NatureRollSlot:
	call Random
	cp 255
	jr z, NatureRollSlot
.loop
	cp 5
	jr c, .done
	sub 5
	jr .loop
.done
	inc a
	ld [wNatureSlot], a
	ret

; Versioned stored prefix: Type1 high bits = slot; Type2 high bits = E0;
; CatchRate = nature. Legacy type bytes cannot have the marker.
NatureEnsureMon:
	call NatureInputHL
	jp NatureEnsureAtHL
NatureEnsureAtHL:
	push hl
	ld bc, 6
	add hl, bc
	ld a, [hli]
	and NATURE_FORMAT_MASK
	cp NATURE_FORMAT_TAG
	jr nz, .legacy
	ld a, [hl]
	cp NUM_NATURES
	jr nc, .legacy
	ld [wNatureID], a
	dec hl
	dec hl
	ld a, [hl]
	rlca
	rlca
	rlca
	and 7
	ld [wNatureSlot], a
	and a
	jr z, .repairSlot
	cp 6
	jr nc, .repairSlot
	pop hl
	ret
.repairSlot
	call NatureRollSlot
	jr .write
.legacy
	ld a, [hl]
	cp $f9
	jr c, .newSlot
	cp $fe
	jr nc, .newSlot
	sub $f8
	ld [wNatureSlot], a
	jr .rollNature
.newSlot
	call NatureRollSlot
.rollNature
	call NatureRoll
.write
	pop hl
	jp NatureWriteAtHL

NatureWriteAtHL:
	push hl
	ld bc, 5
	add hl, bc
	ld a, [wNatureSlot]
	rrca
	rrca
	rrca
	and $e0
	ld b, a
	ld a, [hl]
	and $1f
	or b
	ld [hli], a
	ld a, [hl]
	and $1f
	or NATURE_FORMAT_TAG
	ld [hli], a
	ld a, [wNatureID]
	ld [hl], a
	pop hl
	ret

NatureInitializeNewMon:
	ld a, [wIsInBattle]
	cp 1
	jr nz, .fresh
	ld a, [wMonDataLocation]
	and $f
	jr nz, .fresh
	ld a, [wNatureIDs + 1]
	cp NUM_NATURES
	jr nc, .fresh
	ld [wNatureID], a
	ld a, [wNatureEnemySlot]
	and a
	jr z, .fresh
	ld [wNatureSlot], a
	jr .write
.fresh
	call NatureRollSlot
	call NatureRoll
.write
	call NatureInputHL
	push hl
	ld bc, 5
	add hl, bc
	ld a, [wMonHType1]
	ld [hli], a
	ld a, [wMonHType2]
	ld [hl], a
	pop hl
	jp NatureWriteAtHL

NatureRefreshNewTypes:
	call NatureInputDE
	ld a, [hl]
	and $e0
	ld b, a
	ld a, [wMonHType1]
	or b
	ld [hli], a
	ld a, [wMonHType2]
	or NATURE_FORMAT_TAG
	ld [hl], a
	ret

NatureInitializeEnemy:
	ld a, [wIsInBattle]
	cp 2
	jr nz, .wild
	ld a, [wWhichPokemon]
	ld hl, wEnemyMon1
	ld bc, wEnemyMon2 - wEnemyMon1
	call AddNTimes
	call NatureEnsureAtHL
	jr .cache
.wild
	ld a, [wIsInBattle]
	cp 1
	jr nz, .freshWild
	ld a, [wNatureMode]
	bit 1, a
	ret nz ; capture reloads the same wild mon before constructing its record
.freshWild
	call NatureRollSlot
	call NatureRoll
.cache
	ld a, [wNatureID]
	ld [wNatureIDs + 1], a
	ld [wNatureStatSources + 1], a
	ld a, [wNatureSlot]
	ld [wNatureEnemySlot], a
	ld a, [wNatureMode]
	or 2
	ld [wNatureMode], a
	ret

NatureInitializeCapturedBox:
	ld a, [wNatureIDs + 1]
	ld [wNatureID], a
	ld a, [wNatureEnemySlot]
	ld [wNatureSlot], a
	ld hl, wBoxMon1
	jp NatureWriteAtHL

; Rebuild low type bits after evolution, retaining the marker and ability slot.
NatureRefreshEvolvedTypes:
	call NatureInputHL
	call NatureEnsureAtHL
	ld a, [wd11e]
	ld [wd0b5], a
	call GetMonHeader
	call NatureInputHL
	ld de, 5
	add hl, de
	ld a, [hl]
	and $e0
	ld b, a
	ld a, [wMonHType1]
	or b
	ld [hli], a
	ld a, [wMonHType2]
	or NATURE_FORMAT_TAG
	ld [hl], a
	ret

NatureCriticalHitTest:
	xor a
	ld [wCriticalHitOrOHKO], a
	callab ConditionalCriticalCheck
	jr nc, .ordinary
	ld a, 1
	ld [wCriticalHitOrOHKO], a
	ret
.ordinary
	ld a, [H_WHOSETURN]
	and a
	ld a, [wEnemyMonSpecies]
	jr nz, .handleEnemy
	ld a, [wBattleMonSpecies]
.handleEnemy
	ld [wd0b5], a
	call GetMonHeader
	ld a, [wMonHBaseSpeed]
	ld b, a
	srl b                        ; /2 for regular move (effective (base speed / 2)) --> base crit rate
	ld a, [H_WHOSETURN]
	and a
	ld a, [wPlayerMoveEffect]	;joenote - begin storing player move effect
	ld hl, wPlayerMovePower
	ld de, wPlayerBattleStatus2
	jr z, .calcCriticalHitProbability
	ld a, [wEnemyMoveEffect]	;joenote - begin storing enemy move effect
	ld hl, wEnemyMovePower
	ld de, wEnemyBattleStatus2
.calcCriticalHitProbability
;normal hit is (base speed) / 2
;Focus Energy/Dire Hit multiplies the base threshold by 2, 3, or 4.
;High-crit moves multiply that threshold by 2, including when focused.
;;;;;;;;;;;;
;joenote - do not do a critical hit if a special damage move is being used (dragon rage, seismic toss, etc)
	cp SPECIAL_DAMAGE_EFFECT
	ret z
;;;;;;;;;;;;
	ld a, [hld]                  ; read base power from RAM
	and a
	ret z                        ; do nothing if zero
	dec hl
	ld c, [hl]                   ; read move id
	ld a, [de]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	bit GETTING_PUMPED, a        ; test for focus energy
	jr z, .noFocusEnergyUsed	 ;if getting pumped bit not set, then focus energy not used
	inc de ; corresponding BattleStatus3
	ld a, [de]
	and FOCUS_BOOST_MASK
	jr z, .noFocusEnergyUsed
	swap a ; number of extra base thresholds to add (1..3)
	ld h, a
	ld a, b
.focusMultiply
	add b
	jr c, .capcritical
	dec h
	jr nz, .focusMultiply
	ld b, a
.noFocusEnergyUsed
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ld hl, HighCriticalMoves     ; table of high critical hit moves
.Loop
	ld a, [hli]                  ; read move from move table
	cp c                         ; does it match the move about to be used?
	jr z, .HighCritical          ; if so, the move about to be used is a high critical hit ratio move
	inc a                        ; move on to the next move, FF terminates loop
	jr nz, .Loop                 ; check the next move in HighCriticalMoves
	jr .finishcalc         		 ; continue as a normal move
.HighCritical
	sla b ; high-crit moves have a x2 multiplier
	jr nc, .finishcalc
.capcritical
	ld b, $ff					 ; cap at 255/256
.finishcalc
	call NatureAdjustCriticalChance
	ld a, [wNatureResult]
	ld b, a
	push bc
	callab CustomRandomInBattleBank
	pop bc
	ld a, [wCustomRandomValue]
	rlc a
	rlc a
	rlc a
	cp b                         ; check a against calculated crit rate
	ret nc                       ; no critical hit if no borrow
	ld a, $1
	ld [wCriticalHitOrOHKO], a   ; set critical hit flag
	ret

; high critical hit moves
HighCriticalMoves:
	db ICICLE_SPEAR
	db X_SCISSOR
	db STONE_EDGE
	db KARATE_CHOP
	db RAZOR_LEAF
	db CRABHAMMER
	db SLASH
	db DOUBLESLAP
	db DRAGON_RAGE
	db $FF


;joenote
; function to determine if Counter hits and if so, how much damage it does


NatureLinkUnsupported:
	ld hl, NatureLinkUnsupportedText
	jp PrintText
NatureLinkUnsupportedText:
	text "Link play is not"
	line "available with"
	cont "this save format."
	para "NPC trades still"
	line "work normally."
	done

; wNatureID and A=attribute -> ratio A (90/100/110).
NatureGetRatio:
	ld [wNatureAttr], a
	ld b, a
	ld c, 1
	and a
	jr z, .maskReady
.mask
	sla c
	dec b
	jr nz, .mask
.maskReady
	ld a, [wNatureID]
	cp NUM_NATURES
	jr nc, .neutral
	add a
	ld l, a
	ld h, 0
	jr nc, .offset
	inc h
.offset
	ld de, NatureDefinitions
	add hl, de
	ld a, [hli]
	and c
	jr nz, .positive
	ld a, [hl]
	and c
	jr nz, .negative
.neutral
	ld a, 100
	ret
.positive
	ld a, 110
	ret
.negative
	ld a, 90
	ret

NatureResolveStatID:
	call NatureInputHL
	ld de, wBattleMonHP
	ld a, h
	cp d
	jr nz, .enemy
	ld a, l
	cp e
	jr z, .playerCache
.enemy
	ld de, wEnemyMonHP
	ld a, h
	cp d
	jr nz, .stored
	ld a, l
	cp e
	jr z, .enemyCache
.stored
	ld de, -10 ; stat-exp base (species+16) -> Type2 marker (species+6)
	add hl, de
	ld a, [hli]
	and $e0
	cp $e0
	jr nz, .none
	ld a, [hl]
	jr .finish
.playerCache
	ld a, [wNatureMode]
	bit 0, a
	jr z, .none
	ld a, [wNatureStatSources]
	jr .finish
.enemyCache
	ld a, [wNatureMode]
	bit 1, a
	jr z, .none
	ld a, [wNatureStatSources + 1]
	jr .finish
.none
	ld a, $ff
.finish
	ld [wNatureID], a
	ret

NatureApplyStat:
	call NatureResolveStatID
	ld a, [wNatureInputBC + 1]
	dec a
	cp 5
	ret nc
	call NatureGetRatio
	cp 100
	ret z
	ld [H_MULTIPLIER], a
	xor a
	ld [H_MULTIPLICAND], a
	call Multiply
	ld a, 100
	ld [H_DIVISOR], a
	ld b, 4
	call Divide
	ld a, [H_QUOTIENT + 2]
	cp 3
	jr c, .minimum
	jr nz, .cap
	ld a, [H_QUOTIENT + 3]
	cp 232
	jr c, .minimum
.cap
	ld a, 3
	ld [H_QUOTIENT + 2], a
	ld a, 231
	ld [H_QUOTIENT + 3], a
.minimum
	ld a, [H_QUOTIENT + 2]
	ld b, a
	ld a, [H_QUOTIENT + 3]
	or b
	ret nz
	inc a
	ld [H_QUOTIENT + 3], a
	ret

; Convert only unversioned party records when an old save is loaded. Boxes
; migrate on access, before any prefix copies; daycare is migrated in WRAM.
NatureMigrateParty:
	ld a, [wSaveFileStatus]
	cp 2
	ret nz
	xor a
	ld [wNatureIndex], a
.loop
	ld a, [wPartyCount]
	ld b, a
	ld a, [wNatureIndex]
	cp b
	jr nc, .daycare
	ld hl, wPartyMon1
	ld bc, wPartyMon2 - wPartyMon1
	call AddNTimes
	ld a, h
	ld [wNatureMonPtr], a
	ld a, l
	ld [wNatureMonPtr + 1], a
	ld de, 6
	add hl, de
	ld a, [hl]
	and $e0
	cp $e0
	jr z, .next
	call NatureMigrateOne
.next
	ld hl, wNatureIndex
	inc [hl]
	jr .loop
.daycare
	ld a, [wDayCareInUse]
	and a
	ret z
	ld hl, wDayCareMon
	jp NatureEnsureAtHL

NatureMigrateOne:
	ld a, [wNatureMonPtr]
	ld h, a
	ld a, [wNatureMonPtr + 1]
	ld l, a
	call NatureEnsureAtHL
	ld a, [hl]
	ld [wd0b5], a
	push hl
	call GetMonHeader
	pop hl
	inc hl
	ld a, [hli]
	ld [wNatureOldHP], a
	ld a, [hl]
	ld [wNatureOldHP + 1], a
	ld de, wPartyMon1MaxHP - (wPartyMon1HP + 1)
	add hl, de
	ld a, [hli]
	ld [wNatureOldMax], a
	ld a, [hld]
	ld [wNatureOldMax + 1], a
	push hl
	ld de, wPartyMon1Level - wPartyMon1MaxHP
	add hl, de
	ld a, [hl]
	ld [wCurEnemyLVL], a
	pop de
	ld a, [wNatureMonPtr]
	ld h, a
	ld a, [wNatureMonPtr + 1]
	ld l, a
	ld bc, wPartyMon1HPExp - 1 - wPartyMon1
	add hl, bc
	ld b, 1
	call CalcStats
	ld a, [wNatureMonPtr]
	ld h, a
	ld a, [wNatureMonPtr + 1]
	ld l, a
	push hl
	ld de, wPartyMon1MaxHP - wPartyMon1
	add hl, de
	ld a, [hli]
	ld b, a
	ld c, [hl] ; new maximum
	ld a, [wNatureOldHP]
	ld d, a
	ld a, [wNatureOldHP + 1]
	ld e, a
	or d
	jr z, .storeHP ; never revive a fainted Pokémon
	ld a, [wNatureOldMax + 1]
	sub e
	ld e, a
	ld a, [wNatureOldMax]
	sbc d
	ld d, a ; damage missing from old max
	jr nc, .subtractDamage
	ld de, 0
.subtractDamage
	ld a, c
	sub e
	ld e, a
	ld a, b
	sbc d
	ld d, a
	jr c, .one
	or e
	jr nz, .storeHP
.one
	ld de, 1
.storeHP
	pop hl
	inc hl
	ld [hl], d
	inc hl
	ld [hl], e
	ret

NaturePrepareLoadedMon:
	ld a, [wMonDataLocation]
	cp BOX_DATA
	jp z, NaturePrepareOldBox
	cp DAYCARE_DATA
	jp z, NaturePrepareOldBox
	jp NatureEnsureMon
NaturePrepareTransferMon:
	ld a, [wMoveMonType]
	and a
	jp z, NaturePrepareOldBox
	cp DAYCARE_TO_PARTY
	jp z, NaturePrepareOldBox
	jp NatureEnsureMon

; Box records have no stored maximum HP. Recover the old maximum from the
; unchanged species/DVs/EVs/deposit level before assigning an old record's ID.
NaturePrepareOldBox:
	call NatureInputHL
	push hl
	ld de, 6
	add hl, de
	ld a, [hl]
	and $e0
	cp $e0
	pop hl
	jp z, NatureEnsureAtHL
	ld a, h
	ld [wNatureMonPtr], a
	ld a, l
	ld [wNatureMonPtr + 1], a
	ld a, [wCurEnemyLVL]
	push af
	ld a, [hl]
	ld [wd0b5], a
	push hl
	call GetMonHeader
	pop hl
	inc hl
	ld a, [hli]
	ld [wNatureOldHP], a
	ld a, [hli]
	ld [wNatureOldHP + 1], a
	ld a, [hl] ; deposited level
	and a
	jr nz, .level
	inc a
.level
	ld [wCurEnemyLVL], a
	ld de, 13 ; species+3 -> stat-exp base+16
	add hl, de
	ld bc, $0101
	call CalcStat
	ld a, [H_MULTIPLICAND + 1]
	ld [wNatureOldMax], a
	ld a, [H_MULTIPLICAND + 2]
	ld [wNatureOldMax + 1], a
	ld a, [wNatureMonPtr]
	ld h, a
	ld a, [wNatureMonPtr + 1]
	ld l, a
	call NatureEnsureAtHL
	ld de, 16
	add hl, de
	ld bc, $0101
	call CalcStat
	ld a, [H_MULTIPLICAND + 1]
	ld b, a
	ld a, [H_MULTIPLICAND + 2]
	ld c, a
	call NatureStoreMigratedHP
	pop af
	ld [wCurEnemyLVL], a
	ret

NatureStoreMigratedHP:
	ld a, [wNatureOldHP]
	ld d, a
	ld a, [wNatureOldHP + 1]
	ld e, a
	or d
	jr z, .store
	ld a, [wNatureOldMax + 1]
	sub e
	ld e, a
	ld a, [wNatureOldMax]
	sbc d
	ld d, a
	jr nc, .subtract
	ld de, 0
.subtract
	ld a, c
	sub e
	ld e, a
	ld a, b
	sbc d
	ld d, a
	jr c, .one
	or e
	jr nz, .store
.one
	ld de, 1
.store
	ld a, [wNatureMonPtr]
	ld h, a
	ld a, [wNatureMonPtr + 1]
	ld l, a
	inc hl
	ld [hl], d
	inc hl
	ld [hl], e
	ret

; A=side -> that Pokémon's permanent nature, or FF for an uninitialized
; synthetic battle fixture. Copied battle stats do not copy this identity.
NatureReadSideID:
	and a
	jr nz, .enemy
	ld a, [wNatureMode]
	bit 0, a
	jr z, .none
	ld a, [wNatureIDs]
	jr .store
.enemy
	ld a, [wNatureMode]
	bit 1, a
	jr z, .none
	ld a, [wNatureIDs + 1]
	jr .store
.none
	ld a, $ff
.store
	ld [wNatureID], a
	ret

NatureApplyHitChance:
	ld a, [H_WHOSETURN]
	call NatureReadSideID
	ld a, NATURE_ACCURACY
	call NatureGetRatio
	ld [wNatureAttRatio], a
	ld a, [H_WHOSETURN]
	xor 1
	call NatureReadSideID
	ld a, NATURE_EVASION
	call NatureGetRatio
	ld [wNatureDefRatio], a
	ld b, a
	ld a, [wNatureAttRatio]
	cp b
	ret z ; equal factors cancel without a rounding loss
	ld [H_MULTIPLIER], a
	xor a
	ld [H_MULTIPLICAND], a
	call Multiply
	ld a, [wNatureDefRatio]
	ld [H_DIVISOR], a
	ld b, 4
	jp Divide

NatureAdjustCriticalChance:
	ld a, b
	ld [wNatureResult], a
	ld a, [H_WHOSETURN]
	call NatureReadSideID
	ld a, NATURE_CRIT
	call NatureGetRatio
	ld [H_MULTIPLIER], a
	xor a
	ld [H_MULTIPLICAND], a
	ld [H_MULTIPLICAND + 1], a
	ld a, [wNatureResult]
	ld [H_MULTIPLICAND + 2], a
	call Multiply
	ld a, 100
	ld [H_DIVISOR], a
	ld b, 4
	call Divide
	ld a, [H_QUOTIENT + 2]
	and a
	ld a, [H_QUOTIENT + 3]
	jr z, .store
	ld a, 255
.store
	ld [wNatureResult], a
	ret

; No nature names or hand-written descriptions: decode the two ROM masks.
PartyNaturePanel:
	call ClearSprites
	call SaveScreenTilesToBuffer1
	ld a, [wWhichPokemon]
	ld hl, wPartyMon1
	ld bc, wPartyMon2 - wPartyMon1
	call AddNTimes
	call NatureEnsureAtHL
	ld a, [wNatureID]
	add a
	ld l, a
	ld h, 0
	jr nc, .definition
	inc h
.definition
	ld de, NatureDefinitions
	add hl, de
	ld a, [hli]
	ld [wNaturePosMask], a
	ld a, [hl]
	ld [wNatureNegMask], a
	call ClearScreen
	coord hl, 0, 0
	lb bc, 16, 18
	call TextBoxBorder
	ld hl, wPartyMonNicks
	ld a, [wWhichPokemon]
	call SkipFixedLengthTextEntries
	ld d, h
	ld e, l
	coord hl, 2, 2
	call PlaceString
	coord hl, 2, 4
	ld de, NatureHeading
	call PlaceString
	coord hl, 2, 6
	ld de, NatureRaises
	ld a, [wNaturePosMask]
	call NaturePrintMask
	coord hl, 2, 10
	ld de, NatureLowers
	ld a, [wNatureNegMask]
	call NaturePrintMask
	coord hl, 2, 15
	ld de, NatureCloseHelp
	call PlaceString
.wait
	call DelayFrame
	call JoypadLowSensitivity
	ld a, [hJoy5]
	and A_BUTTON | B_BUTTON | SELECT
	jr z, .wait
	jp LoadScreenTilesFromBuffer1

; A=mask, HL=first row, DE=Raises/Lowers prefix. At most two set bits.
NaturePrintMask:
	ld [wNatureTemp], a
	ld a, h
	ld [wNatureOldHP], a
	ld a, l
	ld [wNatureOldHP + 1], a
	call PlaceString
	ld h, b
	ld l, c
	ld [hl], " "
	inc hl
	ld a, h
	ld [wNatureOldMax], a
	ld a, l
	ld [wNatureOldMax + 1], a
	xor a
	ld [wNatureAttr], a
.scan
	ld a, [wNatureTemp]
	srl a
	ld [wNatureTemp], a
	jr nc, .nextAttribute
	ld a, [wNatureAttr]
	add a
	ld c, a
	ld b, 0
	ld hl, NatureAttributePointers
	add hl, bc
	ld a, [hli]
	ld d, [hl]
	ld e, a
	ld a, [wNatureOldMax]
	ld h, a
	ld a, [wNatureOldMax + 1]
	ld l, a
	call PlaceString
	ld a, [wNatureTemp]
	and a
	ret z
	ld a, [wNatureOldHP]
	ld h, a
	ld a, [wNatureOldHP + 1]
	ld l, a
	ld bc, 2 * SCREEN_WIDTH
	add hl, bc
	ld a, h
	ld [wNatureOldHP], a
	ld a, l
	ld [wNatureOldHP + 1], a
	ld de, NatureAnd
	call PlaceString
	ld h, b
	ld l, c
	ld [hl], " "
	inc hl
	ld a, h
	ld [wNatureOldMax], a
	ld a, l
	ld [wNatureOldMax + 1], a
.nextAttribute
	ld hl, wNatureAttr
	inc [hl]
	jr .scan
NatureHeading:
	db "NATURE@"
NatureRaises:
	db "Raises@"
NatureLowers:
	db "Lowers@"
NatureAnd:
	db "and@"
NatureCloseHelp:
	db "A/B CLOSE@"
NatureAttributePointers:
	dw NatureHP, NatureAttack, NatureDefense, NatureSpeed, NatureSpecial, NatureAccuracy, NatureCrit, NatureEvasion
NatureHP:
	db "HP@"
NatureAttack:
	db "ATTACK@"
NatureDefense:
	db "DEFENSE@"
NatureSpeed:
	db "SPEED@"
NatureSpecial:
	db "SPECIAL@"
NatureAccuracy:
	db "ACCURACY@"
NatureCrit:
	db "CRIT@"
NatureEvasion:
	db "EVASION@"
