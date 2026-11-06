SECTION "Residual move effects", ROMX, BANK[$34]

; Five bytes per active side, in previously unallocated WRAM padding.
; flags: bit 0 rooted, bit 1 cursed, bit 2 newly applied Wrap.
ResidualState:
	ld hl, wPlayerResidual
	ld a, [wCustomSide]
	and a
	ret z
	ld hl, wEnemyResidual
	ret
ResidualClearAll:
	ld hl, wResidualStates
	ld b, 13
	xor a
.clear
	ld [hli], a
	dec b
	jr nz, .clear
	ret
ResidualClearPlayer:
	ld hl, wPlayerResidual
	jr ResidualClearSide
ResidualClearEnemy:
	ld hl, wEnemyResidual
ResidualClearSide:
	ld b, 5
	xor a
.clear
	ld [hli], a
	dec b
	jr nz, .clear
	; Either participant leaving releases both directions of Wrap.
	ld [wPlayerResidual + 2], a
	ld [wEnemyResidual + 2], a
	ret
ResidualPlayerSwitchBlocked:
	xor a
	call ResidualSwitchBlocked
	ret z
	ld hl, ResidualCannotSwitchText
	call PrintText
	ld a, 1
	and a
	ret
ResidualEnemySwitchBlocked:
	ld a, 1
ResidualSwitchBlocked:
	ld [wCustomSide], a
	call ResidualState
	ld a, [hli]
	and 1
	ret nz
	inc hl
	ld a, [hl]
	and a
	ret
ResidualTargetCursed:
	call CustomSetTarget
	call ResidualState
	bit 1, [hl]
	ret
ResidualFullDrain:
	call CustomActorMove
	ld a, [hl]
	cp SHADOW_LEECH
	jr nz, .half
	call ResidualTargetCursed
	ret nz
	call CustomSetTarget
	call UtilityStatusPointer
	ld a, [hl]
	and SLP
	ret
.half
	xor a
	ret

ResidualStatusEffect:
	call UtilityLoadMove
	cp INGRAIN
	jr nz, .curse
	call CustomSetActor
	call ResidualState
	bit 0, [hl]
	jp nz, CustomFailed
	set 0, [hl]
	callab PlayCurrentMoveAnimation
	ld hl, ResidualRootedText
	jp PrintText
.curse
	call CustomSetTarget
	call ResidualState
	bit 1, [hl]
	jp nz, CustomFailed
	call UtilityStatusPointer
	bit PSN, [hl]
	jp nz, CustomFailed
	inc hl
	ld a, [hli]
	cp NORMAL
	jp z, CustomFailed
	ld a, [hl]
	cp NORMAL
	jp z, CustomFailed
	ld hl, wEnemyBattleStatus2
	ld a, [H_WHOSETURN]
	and a
	jr z, .seed
	ld hl, wPlayerBattleStatus2
.seed
	bit SEEDED, [hl]
	jp nz, CustomFailed
	callab CheckTargetSubstitute
	jp nz, CustomFailed
	callab MoveHitTest
	ld a, [wMoveMissed]
	and a
	jp nz, CustomFailed
	call CustomSetTarget
	call ResidualState
	set 1, [hl]
	callab PlayCurrentMoveAnimation
	ld hl, ResidualCursedText
	jp PrintText

ResidualHitEffect:
	ld a, [wMoveMissed]
	and a
	ret nz
	call CustomSetTarget
	call UtilityStatusPointer
	dec hl
	dec hl
	dec hl
	ld a, [hli]
	or [hl]
	ret z
	; Substitute absorbs the secondary persistent effect, even when broken.
	ld a, [wCustomTargetHadSub]
	and a
	ret nz
	call UtilityLoadMove
	cp FIRE_SPIN
	jr nz, .wrap
	call ResidualState
	inc hl
	ld [hl], 3
	ret
.wrap
	cp WRAP
	ret nz
	call ResidualState
	inc hl
	inc hl
	ld a, [hl]
	and a
	ret nz ; repeated hits do not refresh an established timer
	push hl
	call CustomRandom
	pop hl
	ld a, [wCustomRandomValue]
	and 1
	inc a ; 1 or 2 later ticks, plus the initial hit
	ld [hli], a
	ld a, [wDamage]
	ld [hli], a
	ld a, [wDamage + 1]
	ld [hl], a
	call ResidualState
	set 2, [hl] ; skip the application round's additional Wrap tick
	ret

; Called once, after both actions, before starting the next round.
; Existing poison/burn/seed timing remains unchanged.
ResidualEndRound:
	ld a, [wResidualRoundDone]
	and a
	ret nz
	inc a
	ld [wResidualRoundDone], a
	ld a, [H_WHOSETURN]
	ld [wResidualSavedTurn], a
	call ResidualClearFainted
	xor a
	ld [wCustomSide], a
	call ResidualTickSide
	call ResidualClearFainted
	ld a, 1
	ld [wCustomSide], a
	call ResidualTickSide
	call ResidualClearFainted
	ld a, [wResidualSavedTurn]
	ld [H_WHOSETURN], a
	jpab DrawHUDsAndHPBars

ResidualTickSide:
	call ResidualAlive
	ret z
	call ResidualState
	bit 2, [hl]
	res 2, [hl]
	jr nz, .fire
	inc hl
	inc hl
	ld a, [hl]
	and a
	jr z, .fire
	dec [hl]
	inc hl
	ld a, [hli]
	ld [wDamage], a
	ld a, [hl]
	ld [wDamage + 1], a
	; Use the established HP/Substitute rendering paths, but no attack
	; accuracy, crit, Rage, Bide or Counter hooks for these residual ticks.
	ld a, [wCustomSide]
	xor 1
	ld [H_WHOSETURN], a
	call CustomActorMove
	ld a, [de]
	ld [wResidualSavedEffect], a
	ld a, NO_ADDITIONAL_EFFECT
	ld [de], a
	ld a, [wCustomSide]
	and a
	jr nz, .enemyWrap
	callab ApplyAttackToPlayerPokemon
	jr .wrapDone
.enemyWrap
	callab ApplyAttackToEnemyPokemon
.wrapDone
	call CustomActorMove
	ld a, [wResidualSavedEffect]
	ld [de], a
	call UtilitySyncParty
	ld hl, ResidualWrappedText
	call PrintText
.fire
	call ResidualAlive
	ret z
	call ResidualState
	inc hl
	ld a, [hl]
	and a
	jr z, .curse
	dec [hl]
	ld a, 4
	ld [wCustomDelta], a
	xor a
	ld [wCustomChance], a
	call ResidualFraction
	ld hl, ResidualFireText
	call PrintText
.curse
	call ResidualAlive
	ret z
	call ResidualState
	bit 1, [hl]
	jr z, .root
	ld a, 3
	ld [wCustomDelta], a
	xor a
	ld [wCustomChance], a
	call ResidualFraction
	ld hl, ResidualCurseTickText
	call PrintText
.root
	call ResidualAlive
	ret z
	call ResidualState
	bit 0, [hl]
	ret z
	ld a, 4
	ld [wCustomDelta], a
	ld a, 1
	ld [wCustomChance], a
	call ResidualFraction
	ld hl, ResidualRootTickText
	jp PrintText

ResidualAlive:
	call UtilityStatusPointer
	dec hl
	dec hl
	dec hl
	ld a, [hli]
	or [hl]
	ret

; CustomSide selects recipient. Delta is divisor shift (3 or 4), Chance
; selects damage (0) or healing (1). Uses full-width HP, minimum one.
ResidualFraction:
	call UtilityStatusPointer
	ld bc, wBattleMonMaxHP - wBattleMonStatus
	add hl, bc
	ld a, [hli]
	ld c, [hl]
	ld b, a
	ld a, [wCustomDelta]
.shift
	srl b
	rr c
	dec a
	jr nz, .shift
	ld a, b
	or c
	jr nz, .nonzero
	inc c
.nonzero
	push bc
	call UtilityStatusPointer
	dec hl
	dec hl
	dec hl
	ld d, h
	ld e, l
	ld a, [hli]
	ld l, [hl]
	ld h, a
	pop bc
	ld a, [wCustomChance]
	and a
	jr nz, .heal
	ld a, l
	sub c
	ld l, a
	ld a, h
	sbc b
	ld h, a
	jr nc, .store
	ld hl, 0
	jr .store
.heal
	add hl, bc
	jr c, .cap
	push hl
	push de
	call UtilityStatusPointer
	ld bc, wBattleMonMaxHP - wBattleMonStatus
	add hl, bc
	ld a, [hli]
	ld c, [hl]
	ld b, a
	pop de
	pop hl
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
	push de
	call UtilityStatusPointer
	ld bc, wBattleMonMaxHP - wBattleMonStatus
	add hl, bc
	ld a, [hli]
	ld l, [hl]
	ld h, a
	pop de
.store
	ld a, h
	ld [de], a
	inc de
	ld a, l
	ld [de], a
	jp UtilitySyncParty

ResidualRootedText:
	text "Put down roots!"
	prompt
ResidualCursedText:
	text "A curse took hold!"
	prompt
ResidualWrappedText:
	text "Hurt by WRAP!"
	prompt
ResidualFireText:
	text "Hurt by FIRE SPIN!"
	prompt
ResidualCurseTickText:
	text "Hurt by the curse!"
	prompt
ResidualRootTickText:
	text "Roots restored HP!"
	prompt

ResidualCannotSwitchText:
	text "Can't switch now!"
	prompt

; Discourage impossible reapplications without discouraging a coexisting
; burn/sleep/paralysis. This helper is called only for the enemy's status move.
ResidualAIStatusScore:
	xor a
	ld [wCustomRandomValue], a
	ld a, [wEnemyMoveNum]
	cp INGRAIN
	jr nz, .curse
	ld a, [wEnemyResidual]
	and 1
	ret z
	jr .useless
.curse
	ld a, [wPlayerResidual]
	bit 1, a
	jr nz, .useless
	ld a, [wBattleMonStatus]
	bit PSN, a
	jr nz, .useless
	ld a, [wPlayerBattleStatus2]
	and (1 << SEEDED) | (1 << HAS_SUBSTITUTE_UP)
	jr nz, .useless
	ld a, [wPlayerBattleStatus1]
	bit INVULNERABLE, a
	jr nz, .useless
	ld a, [wBattleMonType1]
	and a ; NORMAL = 0
	jr z, .useless
	ld a, [wBattleMonType2]
	and a
	ret nz
.useless
	ld a, 1
	ld [wCustomRandomValue], a
	ret

ResidualClearFainted:
	ld hl, wBattleMonHP
	ld a, [hli]
	or [hl]
	call z, ResidualClearPlayer
	ld hl, wEnemyMonHP
	ld a, [hli]
	or [hl]
	call z, ResidualClearEnemy
	ret
