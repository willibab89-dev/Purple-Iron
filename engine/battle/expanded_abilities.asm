; Shared ability mechanics. This bank has room for the early-species pools.
; Flags per party member: 0 Hot Temper, 1 Confident, 2 low-HP trigger,
; 3 first damaging move spent. Bits 0..2 persist through switching.
AbilityEntry:
	call AbilityFlagsPointer
	res 3, [hl]
	ret

AbilityTarget:
	ld a, [H_WHOSETURN]
	xor 1
	jp AbilityGet

AbilityMove:
	ld hl, wPlayerMoveNum
	ld a, [H_WHOSETURN]
	and a
	ret z
	ld hl, wEnemyMoveNum
	ret

; Percentage roll, exact across the 200 accepted byte values. Result in carry.
; Carry iff draw < percentage*2.
AbilityRoll:
	ld a, b
	add a
	push af
.retry
	callab CustomRandomInBattleBank
	ld a, [wCustomRandomValue]
	cp 200
	jr nc, .retry
	ld b, a
	pop af
	ld c, a
	ld a, b
	cp c
	ret

AbilityScaleDamage:
	ld a, [wDamage]
	ld [H_MULTIPLICAND + 1], a
	ld a, [wDamage + 1]
	ld [H_MULTIPLICAND + 2], a
	xor a
	ld [H_MULTIPLICAND], a
	ld a, c
	ld [H_MULTIPLIER], a
	call Multiply
	ld a, 100
	ld [H_DIVISOR], a
	ld b, 4
	call Divide
	ld a, [H_QUOTIENT + 2]
	ld [wDamage], a
	ld b, a
	ld a, [H_QUOTIENT + 3]
	ld [wDamage + 1], a
	or b
	ret nz
	; Preserve type immunities: only nonzero input damage may become minimum 1.
	ret

AbilityModifyDamage:
	ld a, [wUnusedC000]
	bit 4, a
	ret nz ; fixed damage ignores ordinary damage modifiers
	ld a, [wDamage]
	ld b, a
	ld a, [wDamage + 1]
	or b
	ret z
	ld hl, wPlayerMovePower
	ld a, [H_WHOSETURN]
	ld [wAbilitySide], a
	and a
	jr z, .power
	ld hl, wEnemyMovePower
.power
	ld a, [hli]
	and a
	ret z
	ld a, [hl]
	ld [wAbilityMoveType], a
	call AbilityActor
	cp AB_OVERGROWTH
	jr nz, .blaze
	ld a, [wAbilityMoveType]
	cp GRASS
	jp nz, .defender
	call AbilityHP
	ld a, [de]
	cp [hl]
	jp nz, .defender
	inc de
	inc hl
	ld a, [de]
	cp [hl]
	jp nz, .defender
	jr .quarter
.blaze
	cp AB_BLAZE
	jr nz, .water
	ld a, [wAbilityMoveType]
	cp FIRE
	jp nz, .defender
	call AbilityBelowThird
	jp nc, .defender
	jr .quarter
.water
	cp AB_WATER_PRESSURE
	jr nz, .psionic
	ld a, [wAbilityMoveType]
	cp WATER
	jp nz, .defender
	ld a, [wAbilityPPLeft]
	cp 25
	jr c, .pp
	ld a, 25
.pp
	add a
	add 100
	ld c, a
	call AbilityScaleDamage
	jp .defender
.psionic
	cp AB_PSIONIC
	jr nz, .venomous
	ld a, [wAbilityMoveType]
	cp PSYCHIC
	jp nz, .defender
	ld c, 120
	call AbilityScaleDamage
	jp .defender
.venomous
	cp AB_VENOMOUS
	jr nz, .piercing
	call AbilityTargetStatus
	bit PSN, [hl]
	jr z, .defender
.quarter
	ld c, 125
	call AbilityScaleDamage
	jp .defender
.piercing
	cp AB_PIERCING_STING
	jp nz, .defender
	ld a, [wAbilityMoveType]
	cp POISON
	jp nz, .defender
	call AbilityTargetStatus
	inc hl
	ld a, [hli]
	cp BUG
	jr z, .double
	ld a, [hl]
	cp BUG
	jp nz, .defender
.double
	ld c, 200
	call AbilityScaleDamage
	ld a, [wDamageMultipliers]
	ld b, a
	and $7f
	add a
	ld c, a
	ld a, b
	and $80
	or c
	ld [wDamageMultipliers], a
.defender
	call AbilityTarget
	cp AB_VINE_GUARD
	jr nz, .veil
	ld a, [wAbilityMoveType]
	cp FLYING
	jr z, .half
	ret
.veil
	cp AB_WATER_VEIL
	jr nz, .shell
	ld a, [wAbilityMoveType]
	cp FIRE
	ret nz
.half
	ld c, 50
	jp .reduce
.shell
	cp AB_HARD_SHELL
	ret nz
	ld a, [wAbilityMoveType]
	cp FIRE
	ret nc
	ld c, 75
.reduce
	call AbilityScaleDamage
	ld a, [wDamage]
	ld b, a
	ld a, [wDamage + 1]
	or b
	ret nz
	inc a
	ld [wDamage + 1], a
	ret

AbilityCachePP:
	ld hl, wBattleMonPP
	ld a, [H_WHOSETURN]
	and a
	ld a, [wPlayerMoveListIndex]
	jr z, .read
	ld hl, wEnemyMonPP
	ld a, [wEnemyMoveListIndex]
.read
	and 3
	ld e, a
	ld d, 0
	add hl, de
	ld a, [hl]
	and $3f
	ld [wAbilityPPLeft], a
	ret

; Called only after the Pokémon can actually execute its move.
AbilityAttempt:
	call AbilityCachePP
	call AbilityMove
	ld a, [hl]
	call AbilityMoveFlags
	bit 0, a
	ret z
	ld a, [H_WHOSETURN]
	ld [wAbilitySide], a
	call AbilityFlagsPointer
	set 3, [hl]
	ret

AbilityHitEvents:
	call AbilityMove
	inc hl
	inc hl
	ld a, [hl]
	and a
	ret z
	ld a, [wCustomTargetHadSub]
	and a
	ret nz
	ld a, [wDamage]
	ld b, a
	ld a, [wDamage + 1]
	or b
	ret z
	ld hl, wAbilityHit
	set 0, [hl]
	call AbilityActorMoveType
	ld [wAbilityMoveType], a
	ld a, [H_WHOSETURN]
	xor 1
	ld [wAbilitySide], a
	call AbilityGetTargetReactions
	ld a, [H_WHOSETURN]
	xor 1
	ld [wAbilitySide], a
	call AbilityHP
	ld a, [hli]
	or [hl]
	ret z
	call AbilityLowHPBoth
	ld hl, wAbilityHit
	bit 1, [hl]
	ret nz
	set 1, [hl]
	call AbilityTarget
	cp AB_SHIELD_DUST
	ret z
	call AbilityActor
	cp AB_REPULSIVE
	jr nz, .leaf
	ld b, 10
	call AbilityRoll
	ret nc
	ld hl, wEnemyBattleStatus1
	ld a, [H_WHOSETURN]
	and a
	jr z, .flinch
	ld hl, wPlayerBattleStatus1
.flinch
	set FLINCHED, [hl]
	ret
.leaf
	cp AB_POISON_LEAF
	jr nz, .combustion
	ld a, [wAbilityMoveType]
	cp GRASS
	ret nz
	ld b, 25
	ld c, 1 << PSN
	jr .rollStatus
.combustion
	cp AB_COMBUSTION
	ret nz
	ld a, [wAbilityMoveType]
	cp FIRE
	ret z
	ld b, 15
	ld c, 1 << BRN
.rollStatus
	push bc
	call AbilityRoll
	pop bc
	ret nc
	ld a, c
	ld [wCustomDelta], a
	ld a, [H_WHOSETURN]
	xor 1
	ld [wCustomSide], a
	jp AbilityInflictOrdinaryStatus

AbilityGetTargetReactions:
	call AbilityHP
	ld a, [hli]
	or [hl]
	jp z, .contact
	call AbilityTarget
	cp AB_HOT_TEMPER
	jr nz, .shellGuard
	ld a, [wAbilityMoveType]
	cp FIRE
	jr nc, .contact
	call AbilityFlagsPointer
	bit 0, [hl]
	jr nz, .contact
	set 0, [hl]
	ld a, 3
	call AbilityRaiseStage
	jr .contact
.shellGuard
	cp AB_SHELL_GUARD
	jr nz, .contact
	ld a, [wCriticalHitOrOHKO]
	and a
	jr z, .contact
	ld a, 1
	call AbilityRaiseStage
.contact
	ld hl, wAbilityHit
	bit 2, [hl]
	ret nz
	set 2, [hl]
	call AbilityMove
	ld a, [hl]
	call AbilityMoveFlags
	bit 1, a
	ret z
	call AbilityTarget
	cp AB_DUST_CLOUD
	jr nz, .point
	ld b, 25
	call AbilityRoll
	ret nc
	ld a, [H_WHOSETURN]
	ld [wAbilitySide], a
	ld a, 4
	ld [wCustomStat], a
	ld a, -1
	ld [wCustomDelta], a
	ld a, [wAbilitySide]
	ld [wCustomSide], a
	xor a
	ld [wCustomChanged], a
	jpab CustomChangeStage
.point
	cp AB_POISON_POINT
	jr z, .poison
	cp AB_TOXIC_SHELL
	ret nz
.poison
	ld b, 25
	call AbilityRoll
	ret nc
	; Reverse actor/target for the reactive status, then restore the real turn.
	ld a, [H_WHOSETURN]
	push af
	xor 1
	ld [H_WHOSETURN], a
	xor 1
	ld [wCustomSide], a
	ld a, 1 << PSN
	ld [wCustomDelta], a
	call AbilityInflictOrdinaryStatus
	pop af
	ld [H_WHOSETURN], a
	ret

AbilityLowHPBoth:
	xor a
	ld [wAbilitySide], a
	call AbilityLowHP
	ld a, 1
	ld [wAbilitySide], a
AbilityLowHP:
	ld a, [wAbilitySide]
	call AbilityGet
	cp AB_SURVIVAL_INSTINCTS
	jr z, .speed
	cp AB_FORTIFY
	ret nz
	ld a, 1
	jr .stat
.speed
	ld a, 2
.stat
	push af
	call AbilityBelowThird
	jr nc, .done
	call AbilityFlagsPointer
	bit 2, [hl]
	jr nz, .done
	set 2, [hl]
	pop af
	jp AbilityRaiseStage
.done
	pop af
	ret

AbilityFrenzy:
	call AbilityActor
	cp AB_FRENZY
	ret nz
	ld a, [wAbilityHit]
	and 1
	ret z
	call AbilityTargetStatus
	dec hl
	ld a, [hld]
	or [hl]
	ret nz
	ld a, [H_WHOSETURN]
	ld [wAbilitySide], a
	call AbilityHP
	ld a, [hli]
	or [hl]
	ret z
	xor a
	jp AbilityRaiseStage

AbilityRegeneration:
	call AbilityHP
	ld a, [hli]
	or [hl]
	ret z
	; Use the Photosynthesis amount/cap/sync path without its HP threshold.
	call AbilityHP
	push hl
	jp AbilityPhotosynthesis.notEqual

; Common critical-hit gate runs before guaranteed-critical move rules.
AbilityCriticalGuard:
	xor a
	ld [wAbilityCheckResult], a
	call AbilityTarget
	cp AB_SHELL_ARMOR
	jr z, .block
	cp AB_BATTLE_ARMOR
	ret nz
.block
	ld a, 1
	ld [wAbilityCheckResult], a
	ret
AbilityRuthless:
	call AbilityActor
	cp AB_RUTHLESS
	ret nz
	call AbilityTargetStatus
	ld a, [hl]
	and a
	ret z
	ld a, [wNatureResult]
	add a
	jr nc, .store
	ld a, 255
.store
	ld [wNatureResult], a
	ret

; Shield Dust blocks target-directed secondary effects only. Multi-hit,
; recoil, draining, screen removal and primary trapping effects still execute.
AbilityEffectGate:
	xor a
	ld [wAbilityCheckResult], a
	call AbilityMove
	ld a, [hli]
	ld c, a
	ld a, [hli]
	ld b, a ; effect
	ld a, [hli]
	and a
	ret z ; direct status moves are not blocked by Shield Dust
	call AbilityTarget
	cp AB_SHIELD_DUST
	ret nz
	; Fire's thawing interaction is beneficial, so it is not blocked.
	ld a, b
	cp BURN_SIDE_EFFECT1
	jr z, .thaw
	cp BURN_SIDE_EFFECT2
	jr nz, .secondary
.thaw
	call AbilityTargetStatus
	bit FRZ, [hl]
	ret nz
.secondary
	ld a, b
	ld hl, AbilitySecondaryEffects
	ld de, 1
	push bc
	call IsInArray
	pop bc
	jr c, .block
	ld a, c
	cp TRI_ATTACK
	jr z, .block
	cp SCALD
	jr z, .block
	cp POISON_FANG
	ret nz
.block
	ld a, 1
	ld [wAbilityCheckResult], a
	ret
AbilitySecondaryEffects:
	db POISON_SIDE_EFFECT1, POISON_SIDE_EFFECT2, BURN_SIDE_EFFECT1, BURN_SIDE_EFFECT2
	db FREEZE_SIDE_EFFECT, PARALYZE_SIDE_EFFECT1, PARALYZE_SIDE_EFFECT2
	db FLINCH_SIDE_EFFECT1, FLINCH_SIDE_EFFECT2, CONFUSION_SIDE_EFFECT
	db ATTACK_DOWN_SIDE_EFFECT, DEFENSE_DOWN_SIDE_EFFECT, SPEED_DOWN_SIDE_EFFECT, SPECIAL_DOWN_SIDE_EFFECT
	db ATTACK_AND_STAT_EFFECT, $ff

AbilityBurnGate:
	xor a
	ld [wAbilityCheckResult], a
	ld a, [wCustomDelta]
	cp 1 << BRN
	ret nz
	call AbilityTarget
	cp AB_WATER_VEIL
	ret nz
	ld a, 1
	ld [wAbilityCheckResult], a
	ret

; Accuracy is scaled after nature and stage factors, before final byte cap.
AbilityAccuracy:
	call AbilityActor
	cp AB_COMPOUND_EYES
	jr nz, .target
	ld c, 130
	call AbilityScaleAccuracy
.target
	call AbilityTarget
	cp AB_WONDER_SKIN
	ret nz
	call AbilityMove
	inc hl
	inc hl
	ld a, [hl]
	and a
	ret nz
	ld c, 50
AbilityScaleAccuracy:
	xor a
	ld [H_MULTIPLICAND], a
	ld a, [H_QUOTIENT + 2]
	ld [H_MULTIPLICAND + 1], a
	ld a, [H_QUOTIENT + 3]
	ld [H_MULTIPLICAND + 2], a
	ld a, c
	ld [H_MULTIPLIER], a
	call Multiply
	ld a, 100
	ld [H_DIVISOR], a
	ld b, 4
	jp Divide

; Move metadata: bit0 damaging, bit1 contact. Lists are indexed by move ID.
AbilityMoveFlags:
	cp MAX_MOVE_ID + 1
	jr nc, .invalid
	and a
	ret z
	dec a
	ld e, a
	ld d, 0
	ld hl, AbilityMoveMetadata
	add hl, de
	ld a, [hl]
	ret

.invalid
	xor a
	ret

; Exact signed priorities, including Quick Reflexes stacking with +1 moves.
AbilityPriority:
	call AbilityLowHPBoth
	xor a
	ld [wAbilitySide], a
	call AbilityPriorityOne
	ld [wAbilityTemp], a
	ld a, 1
	ld [wAbilitySide], a
	call AbilityPriorityOne
	ld b, a
	ld a, [wAbilityTemp]
	xor $80
	ld c, a
	ld a, b
	xor $80
	cp c
	ld a, 0
	jr z, .store
	ld a, 1
	jr c, .store
	inc a
.store
	ld [wAbilityCheckResult], a
	ret
AbilityPriorityOne:
	ld a, [wAbilitySide]
	and a
	ld a, [wPlayerSelectedMove]
	jr z, .selected
	ld a, [wEnemySelectedMove]
.selected
	ld [wAbilityTemp + 1], a
	ld b, 0
	cp COUNTER
	jr nz, .positive
	dec b
	jr .quick
.positive
	cp QUICK_ATTACK
	jr z, .plus
	cp AQUA_JET
	jr z, .plus
	cp THUNDERCLAP
	jr z, .plus
	cp AMBUSH
	jr nz, .quick
	push bc
	ld hl, wEnemyMonHP
	ld de, wEnemyMonMaxHP
	ld a, [wAbilitySide]
	and a
	jr z, .ambush
	ld hl, wBattleMonHP
	ld de, wBattleMonMaxHP
.ambush
	call AbilityHalfHP
	pop bc
	jr nc, .quick
.plus
	inc b
.quick
	push bc
	ld a, [wAbilitySide]
	call AbilityGet
	cp AB_QUICK_REFLEXES
	jr nz, .plain
	call AbilityFlagsPointer
	bit 3, [hl]
	jr nz, .plain
	ld a, [wAbilityTemp + 1]
	call AbilityMoveFlags
	bit 0, a
	jr z, .plain
	pop bc
	inc b
	ld a, b
	ret
.plain
	pop bc
	ld a, b
	ret

; HP calculation hook: after nature scaling, before the result is stored.
AbilityAncientHP:
	ld a, [wNatureInputBC + 1]
	cp 1
	ret nz
	ld a, [wNatureInputHL]
	ld h, a
	ld a, [wNatureInputHL + 1]
	ld l, a
	ld de, wEnemyMonHP
	ld a, h
	cp d
	jr nz, .player
	ld a, l
	cp e
	jr nz, .player
	ld a, [wMonHIndex]
	call AbilitySquirtleFamily
	ret nz
	ld a, [wNatureEnemySlot]
	jr .slot
.player
	ld de, wBattleMonHP
	ld a, h
	cp d
	jr nz, .stored
	ld a, l
	cp e
	jr nz, .stored
	ld a, [wActiveAbilities]
	cp AB_ANCIENT
	ret nz
	jr .boost
.stored
	ld de, -16
	add hl, de
	ld a, [hl]
	call AbilitySquirtleFamily
	ret nz
	ld de, 5
	add hl, de
	ld a, [hl]
	rlca
	rlca
	rlca
	and 7
.slot
	cp 3
	ret nz
.boost
	ld c, 120
	call AbilityScaleAccuracy ; same 16-bit quotient scaling, no accuracy cap
	ld a, [H_QUOTIENT + 2]
	cp 3
	jr c, .done
	jr nz, .cap
	ld a, [H_QUOTIENT + 3]
	cp 232
	ret c
.cap
	ld a, 3
	ld [H_QUOTIENT + 2], a
	ld a, 231
	ld [H_QUOTIENT + 3], a
.done
	ret
AbilitySquirtleFamily:
	cp SQUIRTLE
	ret z
	cp WARTORTLE
	ret z
	cp BLASTOISE
	ret

INCLUDE "data/ability_move_metadata.asm"

AbilityDustOnly:
	xor a
	ld [wAbilityCheckResult], a
	call AbilityTarget
	cp AB_SHIELD_DUST
	ret nz
	call AbilityMove
	inc hl
	inc hl
	ld a, [hl]
	and a
	ret z
	ld a, 1
	ld [wAbilityCheckResult], a
	ret

AbilityHalfHP:
	ld a, [hli]
	ld l, [hl]
	ld h, a
	add hl, hl
	jr c, .no
	ld a, [de]
	ld b, a
	inc de
	ld a, [de]
	ld c, a
	ld a, h
	cp b
	ret nz
	ld a, l
	cp c
	ret
.no
	and a
	ret

AbilityPlayerEntry:
	ld hl, wAbilityFlags
	ld a, [wWhichPokemon]
	ld c, a
	ld b, 0
	add hl, bc
	res 3, [hl]
	ret

AbilityVeilOnly:
	xor a
	ld [wAbilityCheckResult], a
	call AbilityTarget
	cp AB_WATER_VEIL
	ret nz
	ld a, 1
	ld [wAbilityCheckResult], a
	ret

; Ability poison is ordinary poison. Poison Fang's shared utility deliberately
; inflicts bad poison, so use a separate status writer for these passives.
AbilityInflictOrdinaryStatus:
	ld a, [wCustomDelta]
	cp 1 << PSN
	jp nz, .burn
	xor a
	ld [wCustomChanged], a
	ld hl, wBattleMonStatus
	ld a, [wCustomSide]
	and a
	jr z, .status
	ld hl, wEnemyMonStatus
.status
	ld a, [hl]
	and a
	ret nz
	push hl
	dec hl
	ld a, [hld]
	or [hl]
	pop hl
	ret z
	inc hl
	ld a, [hli]
	cp POISON
	ret z
	ld a, [hl]
	cp POISON
	ret z
	dec hl
	dec hl
	push hl
	callab ResidualTargetCursed
	pop hl
	ret nz
	ld a, 1 << PSN
	ld [hl], a
	ld hl, wPlayerBattleStatus3
	ld de, wPlayerToxicCounter
	ld a, [wCustomSide]
	and a
	jr z, .clearToxic
	ld hl, wEnemyBattleStatus3
	ld de, wEnemyToxicCounter
.clearToxic
	res BADLY_POISONED, [hl]
	xor a
	ld [de], a
	inc a
	ld [wCustomChanged], a
	callab CustomRecalculate
	callab UtilitySyncParty
	ld hl, AbilityPoisonedText
	jp PrintText
.burn
	jpab UtilityInflictStatus
