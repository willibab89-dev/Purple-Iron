; Shared ability mechanics. This bank has room for the early-species pools.
; Flags per party member: 0 Hot Temper / Quick Feet status, 1 Confident /
; Overcharge, 2 low-HP trigger,
; 3 first damaging move spent; 4..5 Relentless hit count; 6 Intimidate spent;
; 7 already affected by Intimidate. Bits 0..2 and 6..7 persist in battle.
AbilityEntry:
	call AbilityClearRelentless
	call AbilityFlagsPointer
	res 3, [hl]
	ld a, [wAbilitySide]
	call AbilityGet
	cp AB_GREEDY
	jr nz, .entryAbilities
	call AbilityFlagsPointer
	set 6, [hl] ; holder participated in this battle
	ret
.entryAbilities
	cp AB_ILLUSION
	jr z, .resetEntryFlag
	cp AB_ELUSIVE
	ret nz
.resetEntryFlag
	call AbilityFlagsPointer
	res 0, [hl]
	ret

AbilityClearRelentless:
	ld hl, wAbilityFlags
	ld b, 12
.loop
	ld a, [hl]
	and $cf
	ld [hli], a
	dec b
	jr nz, .loop
	ret

; Called after the newly loaded combatant's stat stages are initialized.
AbilityEntrySpeed:
	ld a, [wAbilitySide]
	call AbilityGet
	cp AB_ELUSIVE
	jr nz, .perfume
	call AbilityFlagsPointer
	set 0, [hl]
	ld a, 5 ; Evasion
	call AbilityRaiseStage
.perfume
	ld a, [wAbilitySide]
	call AbilityGet
	cp AB_PERFUME
	jr nz, .tailwind
	ld a, 5 ; Evasion
	call AbilityRaiseStage
.tailwind
	ld a, [wAbilitySide]
	call AbilityGet
	cp AB_TAILWIND
	jr nz, .intimidate
	ld a, 2 ; Speed
	call AbilityRaiseStage
.intimidate
	ld a, [wAbilitySide]
	call AbilityGet
	cp AB_QUICK_FEET
	jr nz, .checkIntimidate
	call AbilityFlagsPointer
	res 0, [hl] ; reapply the boost after stages reset on each entry
	call AbilityQuickFeet
.checkIntimidate
	ld a, [wFirstMonsNotOutYet]
	and a
	jr z, .oneSide
	ld a, [wAbilitySide]
	and a
	ret nz ; first enemy waits until the player's first combatant is ready
	call AbilityIntimidate
	ld a, 1
	ld [wAbilitySide], a
	call AbilityIntimidate
	xor a
	ld [wAbilitySide], a
	ret
.oneSide
	jp AbilityIntimidate

AbilityQuickFeetBoth:
	xor a
	ld [wAbilitySide], a
	call AbilityQuickFeet
	ld a, 1
	ld [wAbilitySide], a
	jp AbilityQuickFeet

AbilityQuickFeet:
	ld a, [wAbilitySide]
	call AbilityGet
	cp AB_QUICK_FEET
	ret nz
	call AbilityHP
	ld a, [hli]
	or [hl]
	ret z
	inc hl
	inc hl ; major status is at HP + 3
	ld a, [hl]
	and a
	jr z, .healthy
	call AbilityFlagsPointer
	bit 0, [hl]
	ret nz
	set 0, [hl]
	ld a, 2 ; Speed
	jp AbilityRaiseStage
.healthy
	call AbilityFlagsPointer
	res 0, [hl]
	ret

; Each holder may trigger once; each target may be affected once per battle.
AbilityIntimidate:
	ld a, [wAbilitySide]
	call AbilityGet
	cp AB_INTIMIDATE
	ret nz
	call AbilityFlagsPointer
	bit 6, [hl]
	ret nz
	ld a, [wAbilitySide]
	xor 1
	ld [wAbilitySide], a
	and a
	jr nz, .targetReady
	; Wild enemy data is loaded before StartBattle and before the player's
	; first mon. InitBattleVariables clears this species even if old HP remains.
	ld a, [wBattleMonSpecies]
	and a
	jr z, .restoreSide
.targetReady
	call AbilityHP
	ld a, [hli]
	or [hl]
	jr z, .restoreSide
	ld a, [wAbilitySide]
	xor 1
	ld [wAbilitySide], a
	call AbilityFlagsPointer
	set 6, [hl]
	ld a, [wAbilitySide]
	xor 1
	ld [wAbilitySide], a
	call AbilityFlagsPointer
	bit 7, [hl]
	jr nz, .restoreSide
	set 7, [hl]
	ld a, 2 ; Speed
	ld [wCustomStat], a
	ld a, [wAbilitySide]
	ld [wCustomSide], a
	ld a, -1
	ld [wCustomDelta], a
	xor a
	ld [wCustomChanged], a
	callab CustomChangeStage
.restoreSide
	ld a, [wAbilitySide]
	xor 1
	ld [wAbilitySide], a
	ret

AbilityTarget:
	ld a, [H_WHOSETURN]
	xor 1
	jp AbilityGet

; Called by CustomChangeStage before modifying a stage.
AbilityKeenEyeCustom:
 xor a
 ld [wAbilityCheckResult], a
 ld a, [wCustomDelta]
 bit 7, a
 ret z
 ld a, [wCustomSide]
 call AbilityGet
 cp AB_CLOUD_NINE
 jr nz, .accuracy
 ld a, [wCustomSide]
 ld b, a
 ld a, [H_WHOSETURN]
 cp b
 jr nz, .block
 ret
.accuracy
 cp AB_KEEN_EYE
 jr z, .checkStat
 cp AB_MIND_READER
 ret nz
.checkStat
 ld a, [wCustomStat]
 cp 4
 ret nz
.block
 ld a, 1
 ld [wAbilityCheckResult], a
 ret

AbilityKeenEyeTarget::
 xor a
 ld [wAbilityCheckResult], a
 call AbilityTarget
 cp AB_CLOUD_NINE
 jr z, .block
 cp AB_KEEN_EYE
 jr z, .accuracy
 cp AB_MIND_READER
 ret nz
.accuracy
 ld a, [wCustomStat]
 cp 4
 ret nz
.block
 ld a, 1
 ld [wAbilityCheckResult], a
 ret

AbilityDampCheck:
 xor a
 ld [wAbilityCheckResult], a
 call AbilityMove
 inc hl
 ld a, [hl]
 cp EXPLODE_EFFECT
 ret nz
 call AbilityTarget
 cp AB_DAMP
 ret nz
 ld a, 1
 ld [wAbilityCheckResult], a
 ret

AbilityPiercingBeakCheck:
	xor a
	ld [wAbilityCheckResult], a
	call AbilityActor
	cp AB_PIERCING_BEAK
	jr z, .beak
	cp AB_PIERCING_HORN
	ret nz
	call AbilityActorMoveType
	cp FIRE
	ret nc
	ld a, 2
	jr .store
.beak
	call AbilityActorMoveType
	cp FLYING
	ret nz
	ld a, 1
.store
	ld [wAbilityCheckResult], a
	ret

; Battle type-chart hook: called only for a Rock matchup.
AbilityCorrosiveCheck:
	xor a
	ld [wAbilityCheckResult], a
	ld a, [wMoveType]
	cp POISON
	ret nz
	call AbilityActor
	cp AB_CORROSIVE_VENOM
	ret nz
	ld a, 1
	ld [wAbilityCheckResult], a
	ret

; AI's bit 3 selects whether it is evaluating the player or enemy move.
AbilityCorrosiveAICheck:
	xor a
	ld [wAbilityCheckResult], a
	ld a, [wUnusedC000]
	bit 3, a
	ld a, [wEnemyMoveType]
	jr z, .move
	ld a, [wPlayerMoveType]
.move
	cp POISON
	ret nz
	ld a, [wUnusedC000]
	bit 3, a
	ld a, 1
	jr z, .side
	xor a
.side
	call AbilityGet
	cp AB_CORROSIVE_VENOM
	ret nz
	ld a, 1
	ld [wAbilityCheckResult], a
	ret

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

; The RNG draw is already in wCustomRandomValue. Halving it doubles the
; threshold probability exactly and makes thresholds >=128 guaranteed.
AbilityMeasuredEffectRoll:
	call AbilityActor
	cp AB_MEASURED
	ret nz
	ld a, [wCustomRandomValue]
	srl a
	ld [wCustomRandomValue], a
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
	cp AB_MEASURED
	jr nz, .overgrowth
	ld c, 80
	call AbilityScaleDamage
	ld a, [wDamage]
	ld b, a
	ld a, [wDamage + 1]
	or b
	jr nz, .measuredDone
	inc a
	ld [wDamage + 1], a ; a non-immune damaging move still deals at least 1
.measuredDone
	jp .defender
.overgrowth
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
	cp AB_TINTED_LENS
	jr nz, .notTinted
	ld a, [wCriticalHitOrOHKO]
	cp 2
	jp z, .defender
	ld a, [wDamageMultipliers]
	and $7f
	jp z, .defender
	cp 10
	jp nc, .defender
	ld c, 200
	call AbilityScaleDamage
	jp .defender
.notTinted
	cp AB_VENOMOUS
	jr nz, .piercing
	call AbilityTargetStatus
	bit PSN, [hl]
	jp z, .defender
.quarter
	ld c, 125
	call AbilityScaleDamage
	jp .defender
.piercing
	cp AB_PIERCING_STING
	jr nz, .newOffense
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
	jp .defender
.newOffense
	cp AB_STRONG_JAW
	jr z, .physicalStrong
	cp AB_HUSTLE
	jr nz, .voltage
	ld c, 125
	jr .physicalBoost
.physicalStrong
	ld c, 115
.physicalBoost
	ld a, [wAbilityMoveType]
	cp FIRE ; physical types precede FIRE
	jp nc, .defender
	call AbilityScaleDamage
	jp .defender
.voltage
	cp AB_VOLTAGE
	jr nz, .sniper
	ld a, [wAbilityMoveType]
	cp ELECTRIC
	jp nz, .defender
	call AbilityTargetStatus
	bit PAR, [hl]
	jp z, .defender
	ld c, 120
	call AbilityScaleDamage
	jp .defender
.sniper
	cp AB_SNIPER
	jr nz, .predator
	ld a, [wCriticalHitOrOHKO]
	and a
	jp z, .defender
	ld c, 150
	call AbilityScaleDamage
	jp .defender
.predator
	cp AB_PREDATOR
	jr nz, .relentless
	ld a, [wAbilityMoveType]
	cp FIRE
	jp nc, .defender
	call AbilityPrepareSpeeds
	ld hl, wAbilityPlayerSpeed
	ld de, wAbilityEnemySpeed
	ld a, [H_WHOSETURN]
	and a
	jr z, .compareSpeed
	ld hl, wAbilityEnemySpeed
	ld de, wAbilityPlayerSpeed
.compareSpeed
	ld a, [de]
	ld b, a
	ld a, [hli]
	cp b
	jp c, .defender
	jr nz, .predatorBoost
	inc de
	ld a, [de]
	ld b, a
	ld a, [hl]
	cp b
	jp c, .defender
	jp z, .defender
.predatorBoost
	ld c, 120
	call AbilityScaleDamage
	jp .defender
.relentless
	cp AB_RELENTLESS
	jr nz, .nidoMale
	ld a, [H_WHOSETURN]
	ld [wAbilitySide], a
	call AbilityFlagsPointer
	ld a, [hl]
	and $30
	swap a
	ld b, a
	add a
	add a
	add b
	add a ; ten percent per prior hit
	add 100
	ld c, a
	call AbilityScaleDamage
	jp .defender
.nidoMale
	cp AB_OPPORTUNIST
	jr nz, .technician
	call AbilityTargetHasLoweredStage
	jp nc, .defender
	ld c, 120
	call AbilityScaleDamage
	jp .defender
.technician
	cp AB_TECHNICIAN
	jr nz, .ambushAbility
	ld a, [wCriticalHitOrOHKO]
	cp 2
	jp z, .defender
	call AbilityMove
	inc hl
	inc hl
	ld a, [hl]
	and a
	jp z, .defender
	cp 61
	jp nc, .defender
	ld c, 150
	call AbilityScaleDamage
	jp .defender
.ambushAbility
	cp AB_AMBUSH
	jr nz, .luckyStar
	ld a, [wCriticalHitOrOHKO]
	cp 2
	jp z, .defender
	ld a, [wAbilityHit]
	bit 4, a
	jp z, .defender
	ld c, 125
	call AbilityScaleDamage
	jp .defender
.luckyStar
	cp AB_LUCKY_STAR
	jr nz, .unpredictable
	ld a, [wCriticalHitOrOHKO]
	cp 2
	jp z, .defender
	ld b, 10
	call AbilityRoll
	jp nc, .defender
	ld c, 150
	call AbilityScaleDamage
	jp .defender
.unpredictable
	cp AB_UNPREDICTABLE
	jr nz, .sheerForce
	ld a, [wCriticalHitOrOHKO]
	cp 2
	jp z, .defender
	ld a, [wAbilityHit]
	bit 4, a
	jp z, .defender
	ld c, 130
	call AbilityScaleDamage
	jp .defender
.sheerForce
	cp AB_SHEER_FORCE
	jr nz, .bloodlust
	ld a, [wCriticalHitOrOHKO]
	cp 2
	jp z, .defender
	call AbilityMove
	ld a, [hl]
	call AbilityMoveFlags
	bit 3, a
	jp z, .defender
	ld c, 120
	call AbilityScaleDamage
	jp .defender
.bloodlust
	cp AB_BLOODLUST
	jr nz, .rampage
	call AbilityBloodlustCheck
	jp nc, .defender
	jr .malePhysicalBoost
.rampage
	cp AB_RAMPAGE
	jp nz, .defender
.malePhysicalBoost
	ld a, [wCriticalHitOrOHKO]
	cp 2
	jp z, .defender
	ld a, [wAbilityMoveType]
	cp FIRE
	jp nc, .defender
	ld c, 125
	call AbilityScaleDamage

.defender
	call AbilityTarget
	cp AB_STENCH
	jr nz, .vineGuard
	call AbilityActorPoisoned
	ret z
	ld c, 75
	jp .reduce
.vineGuard
	cp AB_VINE_GUARD
	jr nz, .veil
	ld a, [wAbilityMoveType]
	cp FLYING
	jr z, .half
	ret
.veil
	cp AB_DAMP
	jr z, .fireHalf
	cp AB_WATER_VEIL
	jr nz, .shell
.fireHalf
	ld a, [wAbilityMoveType]
	cp FIRE
	ret nz
.half
	ld c, 50
	jp .reduce
.shell
	cp AB_HARD_SHELL
	jr nz, .sandArmor
	ld a, [wAbilityMoveType]
	cp FIRE
	ret nc
	ld c, 75
	jr .reduce
.sandArmor
	cp AB_SAND_ARMOR
	jr z, .superEffective
	cp AB_SUBTERRANEAN
	jr nz, .thickHide
.superEffective
	ld a, [wDamageMultipliers]
	and $7f
	cp 11 ; neutral is 10
	ret c
	ld c, 75
	jr .reduce
.thickHide
	cp AB_THICK_FAT
	jr nz, .notThickFat
	ld a, [wAbilityMoveType]
	cp FIRE
	jr z, .half
	cp ICE
	jr z, .half
	ret
.notThickFat
	cp AB_THICK_HIDE
	ret nz
	ld a, [wAbilityMoveType]
	cp FIRE
	ret nc
	ld c, 85
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

; Fixed-damage moves are calculated later than the ordinary damage hook.
; Apply the explicitly requested damage reductions after that calculation.
AbilityFixedDamageModifiers:
	call AbilityExistingFixedDamageModifiers
	jp AbilityIncomingDamage
AbilityExistingFixedDamageModifiers:
	; A missed Jump Kick causes crash damage to its user.
	ld a, [wMoveMissed]
	and a
	jr z, .notCrash
	call AbilityActor
	cp AB_MAGIC_GUARD
	jr nz, .notCrash
	call AbilityMove
	inc hl
	ld a, [hl]
	cp JUMP_KICK_EFFECT
	jr nz, .notCrash
	xor a
	ld [wDamage], a
	ld [wDamage + 1], a
	ret
.notCrash
	ld a, [wUnusedC000]
	bit 4, a
	jr nz, .fixed
	call AbilityMove
	ld a, [hl]
	cp COUNTER
	jr z, .fixed
	cp BIDE
	ret nz
.fixed
	ld a, [wDamage]
	ld b, a
	ld a, [wDamage + 1]
	or b
	ret z
	; Bide releases without the usual AbilityAttempt hook.
	ld a, [wAbilityHit]
	bit 5, a
	jr z, .fixedActor
	call AbilityMove
	ld a, [hl]
	cp BIDE
	jr nz, .fixedActor
	ld hl, wAbilityHit
	set 3, [hl]
.fixedActor
	call AbilityActor
	cp AB_MEASURED
	jr nz, .male
	ld c, 80
	call AbilityScaleDamage
	call AbilityFixedMinimum
	jp .defender
.male
	cp AB_OPPORTUNIST
	jr nz, .ambushAbility
	call AbilityTargetHasLoweredStage
	jp nc, .defender
	ld c, 120
	call AbilityScaleDamage
	jp .defender
.ambushAbility
	cp AB_AMBUSH
	jr nz, .venomous
	ld a, [wCriticalHitOrOHKO]
	cp 2
	jr z, .defender
	ld a, [wAbilityHit]
	bit 4, a
	jr nz, .ambushBoost
	; Bide releases outside AbilityAttempt, so claim its first hit here.
	call AbilityMove
	ld a, [hl]
	cp BIDE
	jr nz, .defender
	ld a, [H_WHOSETURN]
	ld [wAbilitySide], a
	call AbilityFlagsPointer
	bit 3, [hl]
	jr nz, .defender
	set 3, [hl]
	ld hl, wAbilityHit
	set 4, [hl]
.ambushBoost
	ld c, 125
	call AbilityScaleDamage
	jr .defender
.venomous
	cp AB_VENOMOUS
	jr nz, .luckyStar
	call AbilityTargetStatus
	bit PSN, [hl]
	jr z, .defender
	ld c, 125
	call AbilityScaleDamage
	jr .defender
.luckyStar
	cp AB_LUCKY_STAR
	jr nz, .unpredictable
	ld b, 10
	call AbilityRoll
	jr nc, .defender
	ld c, 150
	call AbilityScaleDamage
	jr .defender
.unpredictable
	cp AB_UNPREDICTABLE
	jr nz, .bloodlust
	ld a, [wAbilityHit]
	bit 4, a
	jr z, .defender
	ld c, 130
	call AbilityScaleDamage
	jr .defender
.bloodlust
	cp AB_BLOODLUST
	jr nz, .rampage
	call AbilityBloodlustCheck
	jr nc, .defender
	jr .boost
.rampage
	cp AB_RAMPAGE
	jr nz, .defender
.boost
	call AbilityActorMoveType
	cp FIRE
	jr nc, .defender
	ld c, 125
	call AbilityScaleDamage
.defender
	call AbilityTarget
	cp AB_STENCH
	jr nz, .thickFat
	call AbilityActorPoisoned
	ret z
	ld c, 75
	jr .scale
.thickFat
	cp AB_THICK_FAT
	jr nz, .hide
	call AbilityActorMoveType
	cp FIRE
	jr z, .half
	cp ICE
	ret nz
.half
	ld c, 50
	jr .scale
.hide
	cp AB_THICK_HIDE
	ret nz
	call AbilityActorMoveType
	cp FIRE
	ret nc
	ld c, 85
.scale
	call AbilityScaleDamage
AbilityFixedMinimum:
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
	ld hl, wAbilityHit
	set 3, [hl] ; a move was actually executed this action
	call AbilityMove
	ld a, [hl]
	cp METRONOME
	jr nz, .notMetronome
	call AbilityActor
	cp AB_UNPREDICTABLE
	jr nz, .metronomeDone
	ld hl, wAbilityHit
	set 4, [hl]
.metronomeDone
	ld a, METRONOME
.notMetronome
	call AbilityMoveFlags
	bit 0, a
	jp z, AbilityAttemptStatusMove
	ld a, [H_WHOSETURN]
	ld [wAbilitySide], a
	call AbilityFlagsPointer
	bit 3, [hl]
	jr nz, .alreadySpent
	set 3, [hl]
	call AbilityActor
	cp AB_AMBUSH
	ret nz
	ld hl, wAbilityHit
	set 4, [hl] ; applies to all hits of this first damaging move
	ret
.alreadySpent
	ret

; Ground/Normal abilities trigger only when a move was actually executed.
AbilitySandAfterAction:
	ld a, [wAbilityHit]
	bit 3, a
	ret z
	call AbilityActor
	cp AB_ROLLING_DEFENSE
	jr z, .normal
	cp AB_SAND_VEIL
	jr z, .evasion
	cp AB_BURROWER
	jr nz, .sandRush
	call AbilityActorMoveType
	cp GROUND
	ret nz
	ld a, [H_WHOSETURN]
	ld [wAbilitySide], a
	call AbilityHP
	ld a, [hli]
	or [hl]
	ret z
	dec hl
	ld a, 3 ; 1/8 maximum HP
	jp AbilityHealFractionFromHL
.sandRush
	cp AB_SAND_RUSH
	jr nz, .fox
	call AbilityActorMoveType
	cp GROUND
	ret nz
	ld a, 2 ; Speed
	jr .once
.fox
	cp AB_FOXS_CUNNING
	ret nz
	call AbilityActorMoveType
	cp GHOST
	ret nz
	ld a, 5
	jr .once
.normal
	call AbilityActorMoveType
	cp NORMAL
	ret nz
	ld a, 1 ; Defense
	jr .once
.evasion
	call AbilityActorMoveType
	cp GROUND
	ret nz
	ld a, 5 ; Evasion
.once
	push af
	ld a, [H_WHOSETURN]
	ld [wAbilitySide], a
	call AbilityHP
	ld a, [hli]
	or [hl]
	jr z, .discard
	call AbilityFlagsPointer
	bit 2, [hl]
	jr nz, .discard
	set 2, [hl]
	pop af
	jp AbilityRaiseStage
.discard
	pop af
	ret
AbilityAttemptStatusMove:
	ld a, [H_WHOSETURN]
	ld [wAbilitySide], a
	call AbilityFlagsPointer
	res 4, [hl]
	res 5, [hl]
	ret

AbilityHitEvents:
	call AbilityMove
	inc hl
	inc hl
	ld a, [hl]
	and a
	ret z
	ld a, [wDamage]
	ld b, a
	ld a, [wDamage + 1]
	or b
	ret z
	call AbilityLeeching
	call AbilityAftermath
	call AbilityDeathSpore
	call AbilityRelentlessHit
	call AbilityOvercharge
	call AbilityRampage
	ld a, [wCustomTargetHadSub]
	and a
	ret nz
	call AbilityActorMoveType
	ld [wAbilityMoveType], a
	call AbilitySpinyArmor
	call AbilityEffectSpore
	call AbilityAftershock
	call AbilityToxicScales
	call AbilityParasite
	call AbilityConfounding
	ld a, [wDamage]
	ld b, a
	ld a, [wDamage + 1]
	or b
	ret z
	ld hl, wAbilityHit
	set 0, [hl]
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

; Each successful damaging strike counts, including a hit on a Substitute.
AbilityConfounding:
 ld hl, wAbilityHit
 bit 1, [hl]
 ret nz
 ld a, [H_WHOSETURN]
 xor 1
 ld [wAbilitySide], a
 call AbilityHP
 ld a, [hli]
 or [hl]
 ret z
 call AbilityActor
 cp AB_CONFOUNDING
 ret nz
 ld a, [wAbilityMoveType]
 cp PSYCHIC
 ret nz
 call AbilityTarget
 cp AB_SHIELD_DUST
 ret z
 ld hl, wEnemyBattleStatus1
 ld de, wEnemyConfusedCounter
 ld a, [H_WHOSETURN]
 and a
 jr z, .target
 ld hl, wPlayerBattleStatus1
 ld de, wPlayerConfusedCounter
.target
 bit CONFUSED, [hl]
 ret nz
 push hl
 push de
 ld b, 20
 call AbilityRoll
 pop de
 pop hl
 ret nc
 set CONFUSED, [hl]
 push de
 callab CustomRandomInBattleBank
 pop de
 ld a, [wCustomRandomValue]
 and 3
 add 2
 ld [de], a
 ret

AbilityRelentlessHit:
	call AbilityActor
	cp AB_RELENTLESS
	ret nz
	ld a, [H_WHOSETURN]
	ld [wAbilitySide], a
	call AbilityFlagsPointer
	ld a, [hl]
	and $30
	cp $30
	ret z
	ld a, [hl]
	add $10
	ld [hl], a
	ret

; Each direct physical strike damages the attacker, even if the holder faints.
 ; The attack pipeline records a successful damaging action immediately before
; the HP/substitute path; fixed damage is calculated after this point.
AbilityMarkDirectHit:
	ld a, [wMoveMissed]
	and a
	ret nz
	call AbilityMove
	inc hl
	inc hl
	ld a, [hl]
	and a
	ret z
	ld a, [wDamage]
	ld b, a
	ld a, [wDamage + 1]
	or b
	ret z
	ld hl, wAbilityHit
	set 5, [hl]
	ret

AbilityIncomingDamage:
	ld hl, wAbilityHit
	bit 5, [hl]
	ret z
	res 5, [hl]
	ld a, [wDamage]
	ld b, a
	ld a, [wDamage + 1]
	or b
	ret z
	ld a, [wCustomTargetHadSub]
	and a
	ret nz ; a substitute, rather than the holder, received the hit
	ld a, [H_WHOSETURN]
	xor 1
	ld [wAbilitySide], a
	call AbilityTarget
	cp AB_ILLUSION
	jr z, .illusion
	cp AB_NINE_LIVES
	ret nz
	call AbilityFlagsPointer
	bit 0, [hl]
	ret nz
	call AbilityHP
	ld a, [hli]
	ld b, a
	ld a, [hl]
	ld c, a
	or b
	ret z
	ld a, [wDamage]
	cp b
	jr c, .done
	jr nz, .survive
	ld a, [wDamage + 1]
	cp c
	jr c, .done
.survive
	ld a, [wCriticalHitOrOHKO]
	cp 2
	jr nz, .notOHKO
	xor a
	ld [wCriticalHitOrOHKO], a
.notOHKO
	push bc
	call AbilityFlagsPointer
	set 0, [hl]
	pop bc
	ld a, c
	sub 1
	ld [wDamage + 1], a
	ld a, b
	sbc 0
	ld [wDamage], a
.done
	ret
.illusion
	ld hl, wAbilityHit
	bit 6, [hl]
	jr nz, .halve
	call AbilityFlagsPointer
	bit 0, [hl]
	ret nz
	set 0, [hl]
	ld hl, wAbilityHit
	set 6, [hl] ; the full multi-hit attack is reduced
.halve
	; OHKO moves use 65535 as a sentinel for the target's remaining HP.
	ld a, [wCriticalHitOrOHKO]
	cp 2
	jr nz, .scale
	xor a
	ld [wCriticalHitOrOHKO], a
	call AbilityHP
	ld a, [hli]
	ld [wDamage], a
	ld a, [hl]
	ld [wDamage + 1], a
.scale
	ld c, 50
	call AbilityScaleDamage
	ld a, [wDamage]
	ld b, a
	ld a, [wDamage + 1]
	or b
	ret nz
	inc a
	ld [wDamage + 1], a
	ret

AbilityAftermath:
	ld a, [wCustomTargetHadSub]
	and a
	ret nz
	call AbilityTarget
	cp AB_AFTERMATH
	ret nz
	ld a, [H_WHOSETURN]
	xor 1
	ld [wAbilitySide], a
	call AbilityHP
	ld a, [hli]
	or [hl]
	ret nz
	ld a, [H_WHOSETURN]
	ld [wAbilitySide], a
	call AbilityHP
	ld a, [hli]
	or [hl]
	ret z
	ld hl, wPlayerResidual
	ld a, [H_WHOSETURN]
	and a
	jr z, .curse
	ld hl, wEnemyResidual
.curse
	bit 1, [hl]
	ret nz
	set 1, [hl]
	ld hl, AbilityAftermathText
	jp PrintText
AbilityAftermathText:
	text "AFTERMATH cursed"
	line "the attacker!"
	prompt

 ; Screen bypass is applied only during the damage-stat calculation.
AbilityInfiltratorCheck:
	xor a
	ld [wAbilityCheckResult], a
	ld a, [wAbilityHit]
	bit 3, a ; excludes confusion self-damage and idle calculations
	ret z
	call AbilityActor
	cp AB_INFILTRATOR
	ret nz
	ld a, 1
	ld [wAbilityCheckResult], a
	ret

; Hide only the opposing Substitute flag for the action. The original party
; position is stored in scratch used by other, mutually exclusive abilities.
AbilityInfiltratorStart:
	call AbilityActor
	cp AB_INFILTRATOR
	ret nz
	ld hl, wEnemyBattleStatus2
	ld a, [wEnemyMonPartyPos]
	ld b, a
	ld a, [H_WHOSETURN]
	and a
	jr z, .target
	ld hl, wPlayerBattleStatus2
	ld a, [wPlayerMonNumber]
	ld b, a
.target
	bit HAS_SUBSTITUTE_UP, [hl]
	ret z
	res HAS_SUBSTITUTE_UP, [hl]
	ld a, b
	ld [wAbilityOldStatus], a
	ld hl, wAbilityHit
	set 7, [hl]
	ret

AbilityInfiltratorRestore:
	ld hl, wAbilityHit
	bit 7, [hl]
	ret z
	res 7, [hl]
	ld a, [wIsInBattle]
	and a
	ret z
	ld hl, wEnemyBattleStatus2
	ld a, [wEnemyMonPartyPos]
	ld b, a
	ld a, [H_WHOSETURN]
	and a
	jr z, .target
	ld hl, wPlayerBattleStatus2
	ld a, [wPlayerMonNumber]
	ld b, a
.target
	ld a, [wAbilityOldStatus]
	cp b
	ret nz ; the original target switched out
	set HAS_SUBSTITUTE_UP, [hl]
	ret

; wDamage is the HP actually lost; preserve its quarter until the normal
; drain amount has been calculated by the move effect.
AbilityBloodsuckerCache:
	call AbilityActor
	cp AB_BLOODSUCKER
	jr z, .eligible
	cp AB_ABSORPTION
	ret nz
.eligible
	ld a, [wDamage]
	ld b, a
	ld a, [wDamage + 1]
	ld c, a
	srl b
	rr c
	srl b
	rr c
	ld a, b
	ld [wAbilityTemp], a
	ld a, c
	ld [wAbilityTemp + 1], a
	ret
AbilityBloodsuckerAdd:
	call AbilityActor
	cp AB_BLOODSUCKER
	jr z, .eligible
	cp AB_ABSORPTION
	ret nz
.eligible
	ld a, [wAbilityTemp + 1]
	ld b, a
	ld a, [wDamage + 1]
	add b
	ld [wDamage + 1], a
	ld a, [wAbilityTemp]
	ld b, a
	ld a, [wDamage]
	adc b
	jr nc, .store
	ld a, $ff
	ld [wDamage + 1], a
.store
	ld [wDamage], a
	ret

 ; Leeching uses the actual HP lost, including capped Substitute damage.
AbilityLeeching:
	call AbilityActor
	cp AB_LEECHING
	ret nz
	call AbilityActorMoveType
	cp FIRE
	ret nc
	ld a, [H_WHOSETURN]
	ld [wAbilitySide], a
	call AbilityHP
	ld a, [hli]
	or [hl]
	ret z
	ld a, [wDamage]
	ld b, a
	ld a, [wDamage + 1]
	ld c, a
	or b
	ret z
	ld a, [wCustomTargetHadSub]
	and a
	jr z, .divide
	ld a, [wAbilityTemp + 1]
	ld d, a
	ld a, b
	and a
	jr nz, .capSub
	ld a, c
	cp d
	jr c, .divide
.capSub
	ld b, 0
	ld c, d
.divide
	xor a
	ld [H_DIVIDEND], a
	ld [H_DIVIDEND + 1], a
	ld a, b
	ld [H_DIVIDEND + 2], a
	ld a, c
	ld [H_DIVIDEND + 3], a
	ld a, 10
	ld [H_DIVISOR], a
	ld b, 4
	call Divide
	ld a, [H_QUOTIENT + 2]
	ld b, a
	ld a, [H_QUOTIENT + 3]
	ld c, a
	or b
	jr nz, .heal
	inc c
.heal
	call AbilityHP
	push hl
	ld a, [hli]
	ld l, [hl]
	ld h, a
	add hl, bc
	jr c, .cap
	ld a, [de]
	ld b, a
	inc de
	ld a, [de]
	ld c, a
	ld a, h
	cp b
	jr c, .store
	jr nz, .capBC
	ld a, l
	cp c
	jr c, .store
.capBC
	ld h, b
	ld l, c
	jr .store
.cap
	ld a, [de]
	ld h, a
	inc de
	ld a, [de]
	ld l, a
.store
	ld b, h
	ld c, l
	pop hl
	ld [hl], b
	inc hl
	ld [hl], c
	ld a, [wAbilitySide]
	ld [wCustomSide], a
	callab UtilitySyncParty
	callab DrawHUDsAndHPBars
	ret

; Contact replaces only the active ability, never the saved ability slot.
AbilityParasite:
	call AbilityTarget
	cp AB_PARASITE
	ret nz
	call AbilityMove
	ld a, [hl]
	call AbilityMoveFlags
	bit 1, a
	ret z
	ld a, [H_WHOSETURN]
	ld [wAbilitySide], a
	call AbilityHP
	ld a, [hli]
	or [hl]
	ret z
	ld hl, wActiveAbilities
	ld a, [H_WHOSETURN]
	and a
	jr z, .infect
	inc hl
.infect
	ld a, [hl]
	cp AB_PARASITE
	ret z
	ld [hl], AB_PARASITE
	ld hl, AbilityParasiteText
	jp PrintText
AbilityParasiteText:
	text "PARASITE spread!"
	prompt

; A direct knockout picks Curse or ordinary poison with equal probability.
AbilityDeathSpore:
	ld a, [wCustomTargetHadSub]
	and a
	ret nz
	call AbilityTarget
	cp AB_DEATH_SPORE
	ret nz
	ld a, [H_WHOSETURN]
	xor 1
	ld [wAbilitySide], a
	call AbilityHP
	ld a, [hli]
	or [hl]
	ret nz
	ld a, [H_WHOSETURN]
	ld [wAbilitySide], a
	call AbilityHP
	ld a, [hli]
	or [hl]
	ret z
	callab CustomRandomInBattleBank
	ld a, [wCustomRandomValue]
	and 1
	jr nz, .poison
	ld hl, wPlayerResidual
	ld a, [H_WHOSETURN]
	and a
	jr z, .curse
	ld hl, wEnemyResidual
.curse
	bit 1, [hl]
	ret nz
	set 1, [hl]
	ld hl, AbilityDeathSporeText
	jp PrintText
.poison
	ld a, [H_WHOSETURN]
	push af
	ld [wCustomSide], a
	xor 1
	ld [H_WHOSETURN], a
	ld a, 1 << PSN
	ld [wCustomDelta], a
	call AbilityInflictOrdinaryStatus
	pop af
	ld [H_WHOSETURN], a
	ret
AbilityDeathSporeText:
	text "DEATH SPORE"
	line "cursed its foe!"
	prompt

 ; Carry iff any opposing battle stage is below neutral (7).
AbilityTargetHasLoweredStage:
	ld hl, wEnemyMonStatMods
	ld a, [H_WHOSETURN]
	and a
	jr z, .scan
	ld hl, wPlayerMonStatMods
.scan
	ld b, 6
.loop
	ld a, [hli]
	cp 7
	ret c
	dec b
	jr nz, .loop
	and a
	ret

; Only a participating player's Greedy holder earns the bonus. Battle flags
; alone are insufficient: another ability can use the same flag bit.
AbilityGreedyPrize:
	ld hl, wPartyMon1
	ld de, wAbilityFlags
	ld a, [wPartyCount]
	ld b, a
.loop
	ld a, b
	and a
	ret z
	ld a, [de]
	bit 6, a
	jr z, .next
	push hl
	push de
	push bc
	ld a, [hl]
	cp MEOWTH
	jr z, .species
	cp PERSIAN
	jr nz, .notHolder
.species
	ld bc, 5
	add hl, bc
	ld a, [hli]
	and $e0
	cp 2 << 5
	jr nz, .notHolder
	ld a, [hl]
	and $e0
	cp NATURE_FORMAT_TAG
	jr nz, .notHolder
	pop bc
	pop de
	pop hl
	ld hl, wAmountMoneyWon + 2
	ld d, h
	ld e, l
	ld c, 3
	predef_jump AddBCDPredef
.notHolder
	pop bc
	pop de
	pop hl
.next
	ld a, b
	push af
	ld bc, wPartyMon2 - wPartyMon1
	add hl, bc
	pop af
	ld b, a
	inc de
	dec b
	jr .loop

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

AbilityActorPoisoned:
	ld hl, wBattleMonStatus
	ld a, [H_WHOSETURN]
	and a
	jr z, .check
	ld hl, wEnemyMonStatus
.check
	bit PSN, [hl]
	ret

AbilityToxicWaste:
	ld a, [wAbilitySide]
	xor 1
	ld [wAbilitySide], a
	call AbilityHP
	ld a, [hli]
	or [hl]
	jr z, .noHeal
	inc hl
	inc hl
	bit PSN, [hl]
	jr z, .noHeal
	ld a, [wAbilitySide]
	xor 1
	ld [wAbilitySide], a
	call AbilityHP
	ld a, [hli]
	or [hl]
	ret z
	ld a, [wAbilitySide]
	call AbilityGet
	cp AB_POISON_ABSORB
	ld a, 4
	jr nz, .heal
	dec a
.heal
	push af
	call AbilityHP
	pop af
	jp AbilityHealFractionFromHL
.noHeal
	ld a, [wAbilitySide]
	xor 1
	ld [wAbilitySide], a
	ret

; The entry bonus applies to the first incoming damaging action, including
; misses and Substitute hits; status moves do not consume it.
AbilityElusiveAfterAttack:
	ld a, [wAbilityHit]
	bit 3, a
	ret z
	call AbilityMove
	ld a, [hl]
	cp BIDE
	jr nz, .ordinary
	; Storage is not an attack; a release must have dealt damage.
	ld hl, wPlayerBattleStatus1
	ld a, [H_WHOSETURN]
	and a
	jr z, .bideStatus
	ld hl, wEnemyBattleStatus1
.bideStatus
	bit STORING_ENERGY, [hl]
	ret nz
	ld a, [wDamage]
	ld b, a
	ld a, [wDamage + 1]
	or b
	ret z
	jr .target
.ordinary
	call AbilityMove
	ld a, [hl]
	call AbilityMoveFlags
	bit 0, a
	ret z
.target
	call AbilityTarget
	cp AB_ELUSIVE
	ret nz
	ld a, [H_WHOSETURN]
	xor 1
	ld [wAbilitySide], a
	call AbilityFlagsPointer
	bit 0, [hl]
	ret z
	res 0, [hl]
	call AbilityHP
	ld a, [hli]
	or [hl]
	ret z
	ld a, [wAbilitySide]
	ld [wCustomSide], a
	ld a, 5
	ld [wCustomStat], a
	ld a, -1
	ld [wCustomDelta], a
	xor a
	ld [wCustomChanged], a
	jpab CustomChangeStage

AbilityAftershock:
	call AbilityActor
	cp AB_AFTERSHOCK
	ret nz
	ld a, [wAbilityMoveType]
	cp GROUND
	ret nz
	call AbilityTarget
	cp AB_SHIELD_DUST
	ret z
	ld a, [H_WHOSETURN]
	xor 1
	ld [wAbilitySide], a
	call AbilityHP
	ld a, [hli]
	or [hl]
	ret z
	inc hl
	inc hl
	ld a, [hl]
	and a
	ret nz
	ld b, 20
	call AbilityRoll
	ret nc
	ld a, [H_WHOSETURN]
	xor 1
	ld [wCustomSide], a
	ld a, 1 << PAR
	ld [wCustomDelta], a
	jpab UtilityInflictStatus

; Each physical hit may inflict ordinary poison.
AbilityToxicScales:
	call AbilityActor
	cp AB_TOXIC_SCALES
	ret nz
	ld a, [wAbilityMoveType]
	cp FIRE
	ret nc
	call AbilityTarget
	cp AB_SHIELD_DUST
	ret z
	ld a, [H_WHOSETURN]
	xor 1
	ld [wAbilitySide], a
	call AbilityHP
	ld a, [hli]
	or [hl]
	ret z
	inc hl
	inc hl
	ld a, [hl]
	and a
	ret nz
	ld b, 30
	call AbilityRoll
	ret nc
	ld a, [H_WHOSETURN]
	xor 1
	ld [wCustomSide], a
	ld a, 1 << PSN
	ld [wCustomDelta], a
	jp AbilityInflictOrdinaryStatus

; Choose among the three statuses uniformly; immunities do not reroll.
AbilityEffectSpore:
	call AbilityTarget
	cp AB_EFFECT_SPORE
	ret nz
	ld a, [wAbilityMoveType]
	cp FIRE
	ret nc
	ld a, [H_WHOSETURN]
	ld [wAbilitySide], a
	call AbilityHP
	ld a, [hli]
	or [hl]
	ret z
	inc hl
	inc hl
	ld a, [hl]
	and a
	ret nz
	ld b, 20
	call AbilityRoll
	ret nc
.choose
	callab CustomRandomInBattleBank
	ld a, [wCustomRandomValue]
	and 3
	cp 3
	jr z, .choose
	cp 2
	jr z, .sleep
	ld c, 1 << PSN
	and a
	jr z, .inflict
	ld c, 1 << PAR
.inflict
	ld a, [H_WHOSETURN]
	push af
	ld [wCustomSide], a
	xor 1
	ld [H_WHOSETURN], a
	ld a, c
	ld [wCustomDelta], a
	call AbilityInflictOrdinaryStatus
	pop af
	ld [H_WHOSETURN], a
	ret
.sleep
	callab CustomRandomInBattleBank
	ld a, [wCustomRandomValue]
	and 7
	cp 2
	jr c, .sleep
	ld b, a
	ld a, [H_WHOSETURN]
	ld [wCustomSide], a
	ld hl, wBattleMonStatus
	ld de, wPlayerBattleStatus2
	and a
	jr z, .storeSleep
	ld hl, wEnemyMonStatus
	ld de, wEnemyBattleStatus2
.storeSleep
	ld [hl], b
	ld a, [de]
	res NEEDS_TO_RECHARGE, a
	ld [de], a
	; Sleep interrupts the remaining strikes of a multi-hit move.
	ld hl, wPlayerBattleStatus1
	ld de, wPlayerNumAttacksLeft
	ld a, [H_WHOSETURN]
	and a
	jr z, .interrupt
	ld hl, wEnemyBattleStatus1
	ld de, wEnemyNumAttacksLeft
.interrupt
	bit ATTACKING_MULTIPLE_TIMES, [hl]
	jr z, .syncSleep
	ld a, 1
	ld [de], a
.syncSleep
	callab UtilitySyncParty
	ld hl, AbilityEffectSporeSleepText
	jp PrintText
AbilityEffectSporeSleepText:
	text "Fell asleep!"
	prompt

AbilityRubberSkinCheck:
	xor a
	ld [wAbilityCheckResult], a
	call AbilityActorMoveType
	cp ELECTRIC
	ret nz
	call AbilityTarget
	cp AB_RUBBER_SKIN
	ret nz
	ld a, 1
	ld [wAbilityCheckResult], a
	ret

AbilitySoothingVoice:
	ld a, [wAbilityHit]
	bit 3, a
	ret z
	call AbilityActor
	cp AB_SOOTHING_VOICE
	ret nz
	call AbilityMove
	ld a, [hl]
	call AbilityMoveFlags
	bit 4, a
	ret z
	ld a, [H_WHOSETURN]
	ld [wAbilitySide], a
	call AbilityHP
	ld a, [hli]
	or [hl]
	ret z
	dec hl
	ld a, 3
	jp AbilityHealFractionFromHL

AbilityFoxfire:
	call AbilityActor
	cp AB_FOXFIRE
	ret nz
	ld a, [wAbilityOldStatus]
	bit BRN, a
	ret nz
	call AbilityTargetStatus
	bit BRN, [hl]
	ret z
	ld a, [H_WHOSETURN]
	ld [wAbilitySide], a
	call AbilityHP
	ld a, [hli]
	or [hl]
	ret z
	call AbilityFlagsPointer
	bit 0, [hl]
	ret nz
	set 0, [hl]
	ld a, 3
	jp AbilityRaiseStage

AbilityBloodlustCheck:
	ld a, [H_WHOSETURN]
	xor 1
	ld [wAbilitySide], a
	call AbilityHP
	ld a, [hli]
	or [hl]
	jr z, .no
	dec hl
	jp AbilityHalfHP
.no
	and a
	ret

; Preserve the substitute's pre-hit HP for recoil or healing if it breaks.
AbilityCaptureRampageSubHP:
	call AbilityActor
	cp AB_RAMPAGE
	jr z, .eligible
	cp AB_LEECHING
	ret nz
.eligible
	ld a, [wCustomTargetHadSub]
	and a
	ret z
	ld hl, wEnemySubstituteHP
	ld a, [H_WHOSETURN]
	and a
	jr z, .store
	ld hl, wPlayerSubstituteHP
.store
	ld a, [hl]
	ld [wAbilityTemp + 1], a
	ret

AbilityRampage:
	call AbilityActor
	cp AB_RAMPAGE
	ret nz
	call AbilityActorMoveType
	cp FIRE
	ret nc
	ld a, [H_WHOSETURN]
	ld [wAbilitySide], a
	call AbilityHP
	ld a, [hli]
	or [hl]
	ret z
	ld a, [wDamage]
	ld b, a
	ld a, [wDamage + 1]
	ld c, a
	or b
	ret z
	ld a, [wCustomTargetHadSub]
	and a
	jr z, .divide
	ld a, [wAbilityTemp + 1]
	ld d, a
	ld a, b
	and a
	jr nz, .cap
	ld a, c
	cp d
	jr c, .divide
.cap
	ld b, 0
	ld c, d
.divide
	xor a
	ld [H_DIVIDEND], a
	ld [H_DIVIDEND + 1], a
	ld a, b
	ld [H_DIVIDEND + 2], a
	ld a, c
	ld [H_DIVIDEND + 3], a
	ld a, 10
	ld [H_DIVISOR], a
	ld b, 4
	call Divide
	ld a, [H_QUOTIENT + 2]
	ld b, a
	ld a, [H_QUOTIENT + 3]
	ld c, a
	or b
	jr nz, .amount
	inc c
.amount
	call AbilityHP
	ld a, [hli]
	ld d, a
	ld a, [hl]
	sub c
	ld e, a
	ld a, d
	sbc b
	jr nc, .store
	xor a
	ld e, a
.store
	ld [hl], e
	dec hl
	ld [hl], a
	ld a, [wAbilitySide]
	ld [wCustomSide], a
	callab UtilitySyncParty
	callab DrawHUDsAndHPBars
	ld hl, AbilityRampageText
	jp PrintText
AbilityRampageText:
	text "Hurt by"
	line "RAMPAGE!"
	prompt

AbilitySpinyArmor:
	call AbilityActor
	cp AB_MAGIC_GUARD
	ret z
	call AbilityTarget
	cp AB_SPINY_ARMOR
	ret nz
	ld a, [wAbilityMoveType]
	cp FIRE
	ret nc
	ld a, [H_WHOSETURN]
	ld [wAbilitySide], a
	call AbilityHP
	ld a, [hli]
	or [hl]
	ret z
	dec hl
	push hl
	ld a, [de]
	ld b, a
	inc de
	ld a, [de]
	ld c, a
	rept 4
	srl b
	rr c
	endr
	ld a, b
	or c
	jr nz, .amount
	inc c
.amount
	pop hl
	ld a, [hli]
	ld d, a
	ld a, [hl]
	sub c
	ld e, a
	ld a, d
	sbc b
	jr nc, .store
	xor a
	ld e, a
.store
	ld [hl], e
	dec hl
	ld [hl], a
	ld a, [wAbilitySide]
	ld [wCustomSide], a
	callab UtilitySyncParty
	callab DrawHUDsAndHPBars
	ld hl, AbilitySpinyArmorText
	jp PrintText

AbilitySpinyArmorText:
	text "Hurt by"
	line "SPINY ARMOR!"
	prompt

; A successful critical hit, including against a Substitute, triggers once.
AbilityOvercharge:
	call AbilityActor
	cp AB_OVERCHARGE
	ret nz
	ld a, [wCriticalHitOrOHKO]
	cp 1 ; 2 is an OHKO, not a critical hit
	ret nz
	ld a, [H_WHOSETURN]
	ld [wAbilitySide], a
	call AbilityHP
	ld a, [hli]
	or [hl]
	ret z
	call AbilityFlagsPointer
	bit 1, [hl]
	ret nz
	set 1, [hl]
	ld a, 3 ; Special
	jp AbilityRaiseStage

AbilityShortTemper:
	call AbilityActor
	cp AB_SHORT_TEMPER
	ret nz
	ld a, [wMoveMissed]
	and a
	ret z
	ld a, [wDamageMultipliers]
	and $7f
	ret z ; immunity is not a miss
	ld a, [H_WHOSETURN]
	ld [wAbilitySide], a
	call AbilityHP
	ld a, [hli]
	or [hl]
	ret z
	xor a ; Attack
	jp AbilityRaiseStage

AbilityGetTargetReactions:
	call AbilityHP
	ld a, [hli]
	or [hl]
	jp z, .contact
	call AbilityTarget
	cp AB_INFLATABLE
	jr nz, .hotTemper
	ld a, [wAbilityMoveType]
	cp FIRE
	jr nc, .contact
	ld a, 1 ; Defense
	call AbilityRaiseStage
	jr .contact
.hotTemper
	cp AB_HEADACHE
	jr nz, .swiftSwim
	ld a, [wAbilityMoveType]
	cp FIRE
	jr c, .contact
	call AbilityFlagsPointer
	bit 0, [hl]
	jr nz, .contact
	set 0, [hl]
	ld a, 3
	call AbilityRaiseStage
	jr .contact
.swiftSwim
	cp AB_SWIFT_SWIM
	jr nz, .hotTemperCheck
	ld a, [wAbilityMoveType]
	cp WATER
	jr nz, .contact
	ld a, 2
	call AbilityRaiseStage
	ld a, 2
	call AbilityRaiseStage
	jr .contact
.hotTemperCheck
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
	call AbilityTarget
	cp AB_PHYSICAL_POISON_POINT
	jr nz, .staticCheck
	ld a, [wAbilityMoveType]
	cp FIRE
	ret nc
	jp .poison
.staticCheck
	cp AB_STATIC
	jr nz, .contactMove
	ld a, [wAbilityMoveType]
	cp FIRE ; all physical moves, including ranged moves
	ret nc
	ld a, [H_WHOSETURN]
	ld [wAbilitySide], a
	call AbilityHP
	ld a, [hli]
	or [hl]
	ret z
	ld b, 20
	call AbilityRoll
	ret nc
	ld a, [H_WHOSETURN]
	push af
	ld [wCustomSide], a
	xor 1
	ld [H_WHOSETURN], a
	ld a, 1 << PAR
	ld [wCustomDelta], a
	callab UtilityInflictStatus
	pop af
	ld [H_WHOSETURN], a
	ret
.contactMove
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
	jr nz, .cornered
	ld a, 1
	jr .stat
.cornered
	cp AB_CORNERED
	jr nz, .protective
	xor a ; Attack
	jr .stat
.protective
	cp AB_UNSTABLE
	jr z, .unstable
	cp AB_PROTECTIVE_INSTINCT
	ret nz
	ld a, 1 ; Defense
	push af
	call AbilityHP
	ld a, [hli]
	or [hl]
	jr z, .done
	dec hl
	call AbilityHalfHP
	jr nc, .done
	jr .eligible
.unstable
 call AbilityHP
 ld a, [hli]
 or [hl]
 ret z
 dec hl
 call AbilityHalfHP
 ret nc
 call AbilityFlagsPointer
 bit 2, [hl]
 ret nz
 set 2, [hl]
.randomStat
 callab CustomRandomInBattleBank
 ld a, [wCustomRandomValue]
 and 7
 cp 6
 jr nc, .randomStat
 jp AbilityRaiseStage
.speed
 ld a, 2
.stat
	push af
	call AbilityBelowThird
	jr nc, .done
.eligible
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
	jr z, .directKO
	cp AB_SCAVENGER
	ret nz
.directKO
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
	call AbilityActor
	cp AB_SCAVENGER
	jr z, AbilityHealQuarter
	xor a
	jp AbilityRaiseStage

AbilityHealQuarter:
	call AbilityHP
	ld a, 2
	jp AbilityHealFractionFromHL

; Called at poison damage time; skips poison damage but not Leech Seed.
AbilityMagicGuardActor:
	ld a, [H_WHOSETURN]
	ld [wAbilitySide], a
AbilityMagicGuardCheck:
	xor a
	ld [wAbilityCheckResult], a
	ld a, [wAbilitySide]
	call AbilityGet
	cp AB_MAGIC_GUARD
	ret nz
	ld a, 1
	ld [wAbilityCheckResult], a
	ret

AbilityPoisonHeal:
	xor a
	ld [wAbilityCheckResult], a
	ld a, [H_WHOSETURN]
	ld [wAbilitySide], a
	call AbilityGet
	cp AB_MAGIC_GUARD
	jr nz, .poisonHeal
	ld a, 2
	ld [wAbilityCheckResult], a
	ret
.poisonHeal
	cp AB_POISON_HEAL
	ret nz
	call AbilityHP
	push hl
	inc hl
	inc hl
	inc hl
	ld a, [hl]
	pop hl
	bit PSN, a
	ret z
	ld a, [hli]
	or [hl]
	ret z
	dec hl
	ld a, 1
	ld [wAbilityCheckResult], a
	ld a, 3
	jp AbilityHealFractionFromHL

; Accuracy is stored on a 0..255 scale: 15 percentage points = 38 units.
AbilityHustleAccuracy:
	call AbilityActor
	cp AB_HUSTLE
	ret nz
	call AbilityMove
	inc hl
	inc hl
	ld a, [hli] ; power
	and a
	ret z
	ld a, [hli] ; type
	cp FIRE
	ret nc
	ld a, [hl] ; accuracy
	sub 38
	jr nc, .store
	ld a, 1
.store
	and a
	jr nz, .write
	inc a
.write
	ld [hl], a
	ret

AbilityRegeneration:
	call AbilityHP
	ld a, [hli]
	or [hl]
	ret z
	; Use the Photosynthesis amount/cap/sync path without its HP threshold.
	call AbilityHP
	push hl
	jp AbilityPhotosynthesis.notEqual

AbilityShedSkin:
	ld a, [wAbilitySide]
	call AbilityGet
	cp AB_SHED_SKIN
	ret nz
	call AbilityHP
	ld a, [hli]
	or [hl]
	ret z
	inc hl
	inc hl ; status is HP + 3
	ld a, [hl]
	and a
	ret z
	ld b, 30
	call AbilityRoll
	ret nc
	call AbilityHP
	inc hl
	inc hl
	inc hl
	xor a
	ld [hl], a
	ld hl, wPlayerBattleStatus3
	ld de, wPlayerToxicCounter
	ld a, [wAbilitySide]
	and a
	jr z, .clearToxic
	ld hl, wEnemyBattleStatus3
	ld de, wEnemyToxicCounter
.clearToxic
	res BADLY_POISONED, [hl]
	xor a
	ld [de], a
	ld a, [wAbilitySide]
	ld [wCustomSide], a
	callab CustomRecalculate
	callab UtilitySyncParty
	callab DrawHUDsAndHPBars
	ld hl, AbilityShedSkinText
	jp PrintText

AbilityShedSkinText:
	text "Shed Skin cured"
	line "its condition!"
	prompt

; Common critical-hit gate runs before guaranteed-critical move rules.
AbilityCriticalGuard:
	xor a
	ld [wAbilityCheckResult], a
	call AbilityTarget
	cp AB_SHELL_ARMOR
	jr z, .block
	cp AB_BATTLE_ARMOR
	jr z, .block
	cp AB_IRON_WILL
	ret nz
.block
	ld a, 1
	ld [wAbilityCheckResult], a
	ret
AbilityRuthless:
	call AbilityActor
	cp AB_RUTHLESS
	jr nz, .sharpClaws
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
.sharpClaws
	cp AB_SHARP_CLAWS
	ret nz
	call AbilityActorMoveType
	cp FIRE ; physical types precede FIRE
	ret nc
	ld a, [wNatureResult]
	ld b, a
	srl a
	add b
	jr nc, .store
	ld a, 255
	jr .store

; Shield Dust blocks target-directed secondary effects only. Multi-hit,
; recoil, draining, screen removal and primary trapping effects still execute.
AbilityEffectGate:
	xor a
	ld [wAbilityCheckResult], a
	call AbilityMove
	ld a, [hli]
	ld c, a
	ld a, [hli]
	ld b, a
	ld a, [hli]
	and a
	ret z
	ld a, b
	ld hl, AbilitySecondaryEffects
	ld de, 1
	push bc
	call IsInArray
	pop bc
	jr c, .secondary
	ld a, c
	cp TRI_ATTACK
	jr z, .secondary
	cp SCALD
	jr z, .secondary
	cp POISON_FANG
	ret nz
.secondary
	call AbilityActor
	cp AB_SHEER_FORCE
	jr z, .checkThaw
	call AbilityTarget
	cp AB_SHIELD_DUST
	ret nz
.checkThaw
	ld a, b
	cp BURN_SIDE_EFFECT1
	jr z, .thaw
	cp BURN_SIDE_EFFECT2
	jr nz, .block
.thaw
	call AbilityTargetStatus
	bit FRZ, [hl]
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
	cp AB_MYCELIUM
	jr nz, .pollen
	call AbilityMove
	inc hl
	inc hl
	ld a, [hl]
	and a
	jr nz, .target
	xor a
	ld [H_QUOTIENT + 2], a
	dec a
	ld [H_QUOTIENT + 3], a
	ret
.pollen
	cp AB_POLLEN
	jr nz, .echolocation
	call AbilityMove
	ld a, [hl]
	call AbilityMoveFlags
	bit 5, a
	jr z, .target
	jr .flat20
.echolocation
	cp AB_ECHOLOCATION
	jr nz, .compound
.flat20
	ld a, [H_QUOTIENT + 3]
	add 51 ; 20 percentage points on the 0..255 accuracy scale
	ld [H_QUOTIENT + 3], a
	jr nc, .target
	ld hl, H_QUOTIENT + 2
	inc [hl]
	jr .target
.compound
	cp AB_COMPOUND_EYES
	jr nz, .performer
	ld c, 130
	call AbilityScaleAccuracy
	jr .target
.performer
	cp AB_PERFORMER
	jr nz, .target
	call AbilityMove
	ld a, [hl]
	call AbilityMoveFlags
	bit 4, a
	jr z, .target
	ld c, 120
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
	jr nz, .gale
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
.gale
	cp AB_GALE_WINGS
	jr nz, .plain
	call AbilityHP
	ld a, [de]
	cp [hl]
	jr nz, .plain
	inc de
	inc hl
	ld a, [de]
	cp [hl]
	jr nz, .plain
	ld a, [wAbilityTemp + 1]
	call AbilityMoveFlags
	bit 2, a
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
	call AbilityClearRelentless
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
