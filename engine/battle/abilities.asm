SECTION "Starter ability prototype", ROMX, BANK[$3a]

; Persistent ability slots share the versioned nature record. Legacy F9..FD
; tags are migrated by NatureEnsureMon without rerolling the ability slot.
AbilityFamily:
	ld b, a
	ld hl, AbilitySpeciesPools
.loop
	ld a, [hli]
	and a
	ret z
	cp b
	ld a, [hli]
	ret z
	jr .loop

AbilitySpeciesPools:
	db BULBASAUR, 1
	db IVYSAUR, 1
	db VENUSAUR, 1
	db CHARMANDER, 2
	db CHARMELEON, 2
	db CHARIZARD, 2
	db SQUIRTLE, 3
	db WARTORTLE, 3
	db BLASTOISE, 3
	db CATERPIE, 4
	db METAPOD, 5
	db BUTTERFREE, 6
	db WEEDLE, 7
	db KAKUNA, 8
	db BEEDRILL, 9
	db PIDGEY, 10
	db PIDGEOTTO, 10
	db PIDGEOT, 10
	db RATTATA, 11
	db RATICATE, 11
	db SPEAROW, 12
	db FEAROW, 12
	db EKANS, 13
	db ARBOK, 13
	db PIKACHU, 14
	db RAICHU, 14
	db SANDSHREW, 15
	db SANDSLASH, 16
	db NIDORAN_F, 17
	db NIDORINA, 17
	db NIDOQUEEN, 17
	db NIDORAN_M, 18
	db NIDORINO, 18
	db NIDOKING, 18
	db CLEFAIRY, 19
	db CLEFABLE, 19
	db VULPIX, 20
	db NINETALES, 20
	db JIGGLYPUFF, 21
	db WIGGLYTUFF, 21
	db ZUBAT, 22
	db GOLBAT, 22
	db CROBAT, 22
	db ODDISH, 23
	db GLOOM, 24
	db VILEPLUME, 23
	db PARAS, 25
	db PARASECT, 26
	db VENONAT, 27
	db VENOMOTH, 27
	db DIGLETT, 28
	db DUGTRIO, 28
	db MEOWTH, 29
	db PERSIAN, 29
	db PSYDUCK, 30
	db GOLDUCK, 31
	db MANKEY, 32
	db PRIMEAPE, 32
	db GROWLITHE, 33
	db ARCANINE, 34
	db POLIWAG, 35
	db POLIWHIRL, 35
	db POLIWRATH, 36
	db ABRA, 37
	db KADABRA, 38
	db ALAKAZAM, 38
	db MACHOP, 39
	db MACHOKE, 39
	db MACHAMP, 40
	db BELLSPROUT, 41
	db WEEPINBELL, 41
	db VICTREEBEL, 41
	db TENTACOOL, 42
	db TENTACRUEL, 42
	db GEODUDE, 43
	db GRAVELER, 44
	db GOLEM, 44
	db PONYTA, 45
	db RAPIDASH, 45
	db SLOWPOKE, 46
	db SLOWBRO, 46
	db MAGNEMITE, 47
	db MAGNETON, 47
	db FARFETCHD, 48
	db DODUO, 49
	db DODRIO, 50
	db SEEL, 51
	db DEWGONG, 51
	db GRIMER, 52
	db MUK, 52
	db 0
AbilityPoolIds:
	db AB_POISON_LEAF, AB_CHLOROPHYLL, AB_OVERGROWTH, AB_PHOTOSYNTHESIS, AB_VINE_GUARD
	db AB_BLAZE, AB_COMBUSTION, AB_WILDFIRE, AB_HOT_TEMPER, AB_CONFIDENT
	db AB_WATER_PRESSURE, AB_SHELL_GUARD, AB_ANCIENT, AB_WATER_VEIL, AB_SHELL_ARMOR
	db AB_RUN_AWAY, AB_REPULSIVE, AB_SURVIVAL_INSTINCTS, AB_QUICK_REFLEXES, AB_SHIELD_DUST
	db AB_HARD_SHELL, AB_FORTIFY, AB_REGENERATION, AB_QUICK_REFLEXES, AB_BATTLE_ARMOR
	db AB_COMPOUND_EYES, AB_PSIONIC, AB_DUST_CLOUD, AB_QUICK_REFLEXES, AB_WONDER_SKIN
	db AB_POISON_POINT, AB_REPULSIVE, AB_VENOMOUS, AB_PIERCING_STING, AB_SHIELD_DUST
	db AB_HARD_SHELL, AB_FORTIFY, AB_TOXIC_SHELL, AB_PIERCING_STING, AB_BATTLE_ARMOR
	db AB_RUTHLESS, AB_FRENZY, AB_VENOMOUS, AB_PIERCING_STING, AB_QUICK_REFLEXES
	db AB_TAILWIND, AB_PREDATOR, AB_KEEN_EYE, AB_PIERCING_BEAK, AB_GALE_WINGS
	db AB_SCAVENGER, AB_STRONG_JAW, AB_CORNERED, AB_HUSTLE, AB_POISON_HEAL
	db AB_RUTHLESS, AB_SHORT_TEMPER, AB_RELENTLESS, AB_PIERCING_BEAK, AB_SNIPER
	db AB_INTIMIDATE, AB_SHED_SKIN, AB_VENOMOUS, AB_PREDATOR, AB_CORROSIVE_VENOM
	db AB_STATIC, AB_VOLTAGE, AB_OVERCHARGE, AB_QUICK_REFLEXES, AB_QUICK_FEET
	db AB_ROLLING_DEFENSE, AB_SAND_ARMOR, AB_BURROWER, AB_SHARP_CLAWS, AB_SAND_VEIL
	db AB_SPINY_ARMOR, AB_SAND_ARMOR, AB_BURROWER, AB_SHARP_CLAWS, AB_SAND_VEIL
	db AB_PHYSICAL_POISON_POINT, AB_MEASURED, AB_THICK_HIDE, AB_PROTECTIVE_INSTINCT, AB_IRON_WILL
	db AB_PHYSICAL_POISON_POINT, AB_PIERCING_HORN, AB_SHEER_FORCE, AB_BLOODLUST, AB_RAMPAGE
	db AB_LUCKY_STAR, AB_MAGIC_GUARD, AB_MOON_CHILD, AB_UNPREDICTABLE, AB_WONDER_SKIN
	db AB_AFTERMATH, AB_FOXFIRE, AB_NINE_LIVES, AB_FOXS_CUNNING, AB_ILLUSION
	db AB_INFLATABLE, AB_PERFORMER, AB_RUBBER_SKIN, AB_SOOTHING_VOICE, AB_THICK_FAT
	db AB_ECHOLOCATION, AB_BLOODSUCKER, AB_GALE_WINGS, AB_INFILTRATOR, AB_PREDATOR
	db AB_PERFUME, AB_ABSORPTION, AB_POLLEN, AB_EFFECT_SPORE, AB_PHOTOSYNTHESIS
	db AB_STENCH, AB_ABSORPTION, AB_POLLEN, AB_EFFECT_SPORE, AB_TOXIC_WASTE
	db AB_EFFECT_SPORE, AB_LEECHING, AB_PARASITE, AB_MYCELIUM, AB_REGROWTH
	db AB_EFFECT_SPORE, AB_LEECHING, AB_PARASITE, AB_MYCELIUM, AB_DEATH_SPORE
	db AB_SHIELD_DUST, AB_TOXIC_SCALES, AB_TINTED_LENS, AB_POISON_ABSORB, AB_VENOMOUS
	db AB_AMBUSH, AB_SUBTERRANEAN, AB_ELUSIVE, AB_AFTERSHOCK, AB_SAND_RUSH
	db AB_OPPORTUNIST, AB_GREEDY, AB_RESOURCEFUL, AB_QUICK_REFLEXES, AB_TECHNICIAN
	db AB_HEADACHE, AB_PSIONIC, AB_DAMP, AB_CONFOUNDING, AB_UNSTABLE
	db AB_CLOUD_NINE, AB_SWIFT_SWIM, AB_DAMP, AB_MIND_READER, AB_WATER_VEIL
	db AB_DEFIANT, AB_SHORT_TEMPER, AB_SCRAPPY, AB_UNSOPHISTICATED, AB_BLOODLUST
	db AB_LOYALTY, AB_MOMENTUM, AB_STEADFAST, AB_GROWL_INTIMIDATE, AB_ELEGANT_MANE
	db AB_LEGENDARY, AB_MOMENTUM, AB_STEADFAST, AB_GROWL_INTIMIDATE, AB_ELEGANT_MANE
	db AB_HYPNOTIC, AB_SLIPPERY, AB_SWIFT_SWIM, AB_HYDRATION, AB_WATER_VEIL
	db AB_WRESTLER, AB_SLIPPERY, AB_SWIFT_SWIM, AB_POWER_SWIM, AB_IRON_FIST
	db AB_RUN_AWAY, AB_MENTAL_SHIELD, AB_TELEPATHY, AB_GENIUS, AB_MAGIC_BOUNCE
	db AB_SPOON_BENDER, AB_MAGIC_GUARD, AB_MIND_READER, AB_GENIUS, AB_MAGIC_BOUNCE
	db AB_NO_GUARD, AB_GUTS, AB_IRON_GRIP, AB_GRAPPLER, AB_BODYBUILDER
	db AB_NO_GUARD, AB_GUTS, AB_FOUR_ARMS, AB_GRAPPLER, AB_BODYBUILDER
	db AB_ACIDIC, AB_CARNIVOROUS, AB_STICKY_TRAP, AB_CHLOROPHYLL, AB_DIGESTIVE_ACID
	db AB_CLEAR_BODY, AB_LIQUID_OOZE, AB_STINGING_SKIN, AB_JELLY_BODY, AB_VENOMOUS
	db AB_LEVITATE, AB_IMMUNITY, AB_STURDY, AB_ROLLOUT, AB_HEAVYWEIGHT
	db AB_DIGGER, AB_IMMUNITY, AB_STURDY, AB_ROLLOUT, AB_HEAVYWEIGHT
	db AB_FLAME_BODY, AB_COMPETITIVE, AB_BLAZING_TRAIL, AB_WILD_CHARGE, AB_STAMINA
	db AB_SHELL_ARMOR, AB_OBLIVIOUS, AB_UNAWARE, AB_PATIENT, AB_SIMPLE
	db AB_LEVITATE, AB_BATTERY, AB_OVERLOAD, AB_CHAIN_REACTION, AB_MAGNETIC_FIELD
	db AB_UNDERDOG, AB_UNYIELDING, AB_TASTY_LEEK, AB_PRECISION, AB_RAZOR_EDGE
	db AB_TWIN_BEAKS, AB_STAMPEDE, AB_QUICK_FEET, AB_BIRD_RELENTLESS, AB_HEADSTRONG
	db AB_TRIPLE_THREAT, AB_STAMPEDE, AB_QUICK_FEET, AB_BIRD_RELENTLESS, AB_HEADSTRONG
	db AB_BLUBBER, AB_HYDRATION, AB_REFRIGERATE, AB_ICEBREAKER, AB_SNOW_VEIL
	db AB_CONTAMINATION, AB_GRIMER_TOXIC_WASTE, AB_STICKY_BODY, AB_LIQUID_OOZE, AB_SOFT_BODY

; C = one-based pool number, B = saved slot (1..5).
; A 16-bit offset allows more than 255 pool entries without changing saves.
AbilityResolvePoolId:
	ld a, c
	dec a
	ld l, a
	ld h, 0
	ld d, h
	ld e, l
	add hl, hl
	add hl, hl
	add hl, de ; five entries per pool
	ld a, b
	dec a
	ld e, a
	ld d, 0
	add hl, de
	ld de, AbilityPoolIds
	add hl, de
	ld a, [hl]
	ret

; Nature format keeps the persistent ability slot in stored Type1 high bits.
AbilityEnsureMon:
	naturecall NatureEnsureMon
	ld a, [hl]
	call AbilityFamily
	and a
	jr z, .none
	ld c, a
	ld a, [wNatureSlot]
	ld b, a
	jp AbilityResolvePoolId
.none
	ld b, 0
	ret

AbilityResetBattle:
	xor a
	ld [wRolloutStacks], a
	ld [wRolloutStacks + 1], a
	ld [wPatientActed], a
	ld [wAbilityHit], a
	ld [wAbilityPPLeft], a
	ld [wAbilityCheckResult], a
	ld [wNatureMode], a
	ld hl, wAbilityFlags
	ld b, 14
	xor a
.loop
	ld [hli], a
	dec b
	jr nz, .loop
	ret

AbilityAssignNewMon:
	; NatureInitializeNewMon has already assigned the saved slot.
	jpab AbilityResourcefulNewMon

AbilityLoadPlayer:
	push af
	push bc
	push de
	push hl
	ld a, [wLinkState]
	cp LINK_STATE_BATTLING
	jr z, .disabled
	ld a, [wWhichPokemon]
	ld hl, wPartyMon1
	ld bc, wPartyMon2 - wPartyMon1
	call AddNTimes
	call AbilityEnsureMon
	push af
	ld a, [wNatureID]
	ld [wNatureIDs], a
	ld [wNatureStatSources], a
	ld a, [wNatureMode]
	or 1
	ld [wNatureMode], a
	pop af
	jr .store
.disabled
	xor a
.store
	ld [wActiveAbilities], a
	xor a
	ld [wAbilitySide], a
	call AbilityPlayerEntry
	pop hl
	pop de
	pop bc
	pop af
	ret

; Nature initialization has already cached the stable enemy slot.
AbilityLoadEnemy:
	ld a, [wEnemyMonSpecies2]
	call AbilityFamily
	and a
	jr z, .store
	ld c, a
	ld a, [wNatureEnemySlot]
	ld b, a
	call AbilityResolvePoolId
.store
	ld [wActiveAbilities + 1], a
	ld a, 1
	ld [wAbilitySide], a
	call AbilityEntry
	ld a, [wNatureIDs + 1]
	ld [wAbilityTemp], a
	ret

AbilityGet:
	ld hl, wActiveAbilities
	and a
	jr z, .read
	inc hl
.read
	ld a, [hl]
	ret

AbilityActor:
	ld a, [H_WHOSETURN]
	jp AbilityGet

; wAbilitySide is an absolute side, independent of whose action is executing.
AbilityHP:
	ld hl, wBattleMonHP
	ld de, wBattleMonMaxHP
	ld a, [wAbilitySide]
	and a
	ret z
	ld hl, wEnemyMonHP
	ld de, wEnemyMonMaxHP
	ret

; Carry iff living current HP is strictly less than one third maximum HP.
AbilityBelowThird:
	call AbilityHP
	ld a, [hli]
	ld l, [hl]
	ld h, a
	ld a, h
	or l
	jr z, .no
	ld b, h
	ld c, l
	add hl, hl
	jr c, .no
	add hl, bc
	jr c, .no
	ld a, [de]
	ld b, a
	inc de
	ld a, [de]
	ld c, a
	ld a, h
	cp b
	ret c
	jr nz, .no
	ld a, l
	cp c
	ret
.no
	and a
	ret

AbilityDamageBoost:
	push af
	push bc
	push de
	push hl
	call AbilityModifyDamage
	pop hl
	pop de
	pop bc
	pop af
	ret

AbilityPrepareSpeeds:
	abilitycall AbilityLowHPBoth
	abilitycall AbilityQuickFeetBoth
	call AbilitySteadfastActor
	push af
	push bc
	push de
	push hl
	xor a
	ld [wAbilitySide], a
	call AbilityOneSpeed
	ld a, h
	ld [wAbilityPlayerSpeed], a
	ld a, l
	ld [wAbilityPlayerSpeed + 1], a
	ld a, 1
	ld [wAbilitySide], a
	call AbilityOneSpeed
	ld a, h
	ld [wAbilityEnemySpeed], a
	ld a, l
	ld [wAbilityEnemySpeed + 1], a
	pop hl
	pop de
	pop bc
	pop af
	ret

AbilityOneSpeed:
	ld hl, wBattleMonSpeed
	ld a, [wAbilitySide]
	and a
	jr z, .read
	ld hl, wEnemyMonSpeed
.read
	ld a, [hli]
	ld l, [hl]
	ld h, a
	push hl
	ld a, [wAbilitySide]
	call AbilityGet
	cp 2
	jr nz, .plain
	call AbilityBelowThird
	jr nc, .plain
	pop hl
	ld b, h
	ld c, l
	srl b
	rr c
	add hl, bc
	ret nc
	ld hl, $ffff
	ret
.plain
	pop hl
	ret

AbilityTargetStatus:
	ld hl, wEnemyMonStatus
	ld a, [H_WHOSETURN]
	and a
	ret z
	ld hl, wBattleMonStatus
	ret

AbilityBeforeAction:
	push af
	push bc
	push de
	push hl
	xor a
	ld [wAbilityHit], a
	ld [wMoveMissed], a
	call AbilityTargetStatus
	ld a, [hl]
	ld [wAbilityOldStatus], a
	call AbilityInfiltratorStart
	call AbilitySteadfastActor
	call AbilityCachePP
	pop hl
	pop de
	pop bc
	pop af
	ret

AbilityAfterHit:
	push af
	push bc
	push de
	push hl
	call AbilityHitEvents
	pop hl
	pop de
	pop bc
	pop af
	ret

AbilityActorMoveType:
	ld hl, wPlayerMoveType
	ld a, [H_WHOSETURN]
	and a
	jr z, .read
	ld hl, wEnemyMoveType
.read
	ld a, [hl]
	ret

AbilityFlagsPointer:
	ld hl, wAbilityFlags
	ld a, [wAbilitySide]
	and a
	ld a, [wPlayerMonNumber]
	jr z, .index
	ld hl, wAbilityFlags + 6
	ld a, [wIsInBattle]
	cp 2
	jr z, .trainerIndex
	xor a ; wild enemies have no party position
	jr .index
.trainerIndex
	ld a, [wEnemyMonPartyPos]
	cp 6
	jr c, .index
	xor a ; guard against the pre-send-out sentinel
.index
	ld c, a
	ld b, 0
	add hl, bc
	ret

AbilityRaiseStage:
	ld [wCustomStat], a
	ld a, [wAbilitySide]
	ld [wCustomSide], a
	ld a, 1
	ld [wCustomDelta], a
	xor a
	ld [wCustomChanged], a
	jpab CustomChangeStage

AbilityAfterAction:
	abilitycall AbilityPatientMarkAction
	abilitycall AbilityInfiltratorRestore
	abilitycall AbilityElusiveAfterAttack
	abilitycall AbilityLowHPBoth ; recoil can cross a threshold mid-turn
	abilitycall AbilityFrenzy
	abilitycall AbilityShortTemper
	abilitycall AbilitySandAfterAction
	abilitycall AbilityRolloutAfterAction
	abilitycall AbilityFoxfire
	abilitycall AbilitySoothingVoice
	abilitycall AbilityQuickFeetBoth
	push af
	push bc
	push de
	push hl
	ld a, [H_WHOSETURN]
	ld [wAbilitySide], a
	call AbilityHP
	ld a, [hli]
	or [hl]
	jp z, .done
	call AbilityActor
	cp 8
	jr nz, .confident
	ld a, [wAbilityOldStatus]
	and a
	jr nz, .done
	call AbilityTargetStatus
	bit BRN, [hl]
	jr z, .done
	ld a, [H_WHOSETURN]
	ld [wAbilitySide], a
	xor a ; Attack
	call AbilityRaiseStage
	jr .done
.confident
	cp 10
	jr nz, .done
	ld a, [wMoveMissed]
	and a
	jr z, .done
	ld a, [wDamageMultipliers]
	and $7f
	jr z, .done ; an immunity is not an accuracy miss
	ld hl, wPlayerMovePower
	ld a, [H_WHOSETURN]
	ld [wAbilitySide], a
	and a
	jr z, .power
	ld hl, wEnemyMovePower
.power
	ld a, [hl]
	and a
	jr z, .done
	call AbilityFlagsPointer
	bit 1, [hl]
	jr nz, .done
	set 1, [hl]
	ld a, 4 ; Accuracy
	call AbilityRaiseStage
.done
	pop hl
	pop de
	pop bc
	pop af
	ret

AbilityEndRound:
	call AbilityLowHPBoth
	ld a, [wResidualRoundDone]
	and a
	ret nz
	xor a
	ld [wAbilitySide], a
	call AbilityPhotosynthesis
	ld a, 1
	ld [wAbilitySide], a
	call AbilityPhotosynthesis
	xor a
	ld [wAbilitySide], a
	call AbilityShedSkin
	ld a, 1
	ld [wAbilitySide], a
	call AbilityShedSkin
	jp AbilityQuickFeetBoth
AbilityPhotosynthesis:
	ld a, [wAbilitySide]
	call AbilityGet
	cp AB_REGENERATION
	jp z, AbilityRegeneration
	cp AB_GRIMER_TOXIC_WASTE
	jp z, AbilityGrimerToxicWaste
	cp AB_TOXIC_WASTE
	jr z, .poisonRecovery
	cp AB_POISON_ABSORB
	jr nz, .notToxicWaste
.poisonRecovery
	jp AbilityToxicWaste
.notToxicWaste
	cp AB_MOON_CHILD
	jr z, .unconditionalHeal
	cp AB_REGROWTH
	jr nz, .notMoon
.unconditionalHeal
	call AbilityHP
	ld a, [hli]
	or [hl]
	ret z
	dec hl
	ld a, 4
	jp AbilityHealFractionFromHL
.notMoon
	cp 4
	ret nz
	call AbilityHP
	push hl
	ld a, [hli]
	ld l, [hl]
	ld h, a
	add hl, hl
	ld a, [de]
	ld b, a
	inc de
	ld a, [de]
	ld c, a
	dec de
	ld a, h
	cp b
	jr c, AbilityPhotosynthesisNoHeal
	jr nz, .notEqual
	ld a, l
	cp c
	jr c, AbilityPhotosynthesisNoHeal
	jr z, AbilityPhotosynthesisNoHeal
.notEqual
	pop hl
	ld a, 4 ; 1/16
	jr AbilityHealFractionFromHL

; A = shift count, HL = living holder HP, DE = holder max HP.
AbilityHealFractionFromHL:
	ld [wAbilityTemp + 1], a
	push hl
	ld a, [de]
	ld h, a
	inc de
	ld a, [de]
	ld l, a
	ld b, h
	ld c, l
.shift
	srl b
	rr c
	ld a, [wAbilityTemp + 1]
	dec a
	ld [wAbilityTemp + 1], a
	jr nz, .shift
	ld a, b
	or c
	jr nz, .amount
	inc c
.amount
	pop hl
	push hl
	ld a, [hli]
	ld l, [hl]
	ld h, a
	add hl, bc
	ld a, [de]
	ld c, a
	dec de
	ld a, [de]
	ld b, a
	ld a, h
	cp b
	jr c, .store
	jr nz, .cap
	ld a, l
	cp c
	jr c, .store
.cap
	ld h, b
	ld l, c
.store
	ld b, h
	ld c, l
	pop hl
	ld [hl], b
	inc hl
	ld [hl], c
	ld a, [wAbilitySide]
	ld [wCustomSide], a
	jpab UtilitySyncParty
AbilityPhotosynthesisNoHeal:
	pop hl
	ret

AbilityPoisonedText:
	TX_FAR _PoisonedText
	db "@"
AbilityBurnedText:
	TX_FAR _BurnedText
	db "@"

; Battle inspection: SELECT opens, left/right switches side, B/SELECT closes.
AbilityPanel:
	call SaveScreenTilesToBuffer2
	xor a
	ld [wAbilityPanelSide], a
.draw
	call ClearScreen
	coord hl, 0, 0
	lb bc, 16, 18
	call TextBoxBorder
	coord hl, 2, 2
	ld de, AbilityPlayerLabel
	ld a, [wAbilityPanelSide]
	and a
	jr z, .label
	ld de, AbilityEnemyLabel
.label
	call PlaceString
	ld a, [wAbilityPanelSide]
	call AbilityGet
	call AbilityDrawDescription
	coord hl, 2, 14
	ld de, AbilityPanelHelp
	call PlaceString
.wait
	call DelayFrame
	call JoypadLowSensitivity
	ld a, [hJoy5]
	and B_BUTTON | SELECT
	jr nz, .close
	ld a, [hJoy5]
	and D_LEFT | D_RIGHT
	jr z, .wait
	ld a, [wAbilityPanelSide]
	xor 1
	ld [wAbilityPanelSide], a
	jr .draw
.close
	call LoadScreenTilesFromBuffer2
	ret
AbilityPlayerLabel:
	db "YOUR ABILITY@"
AbilityEnemyLabel:
	db "FOE'S ABILITY@"
AbilityPanelHelp:
	db "LEFT/RIGHT SIDE",$4e,"B/SELECT CLOSE@"
; Description data lives in the expanded ability bank.
AbilityDrawDescription:
	ld [wAbilityTemp], a
	jpab AbilityDrawDescriptionBanked

; Invoked from the overworld party action menu. Buffer 2 contains the saved
; overworld screen, so only buffer 1 may be used here.
PartyAbilityPanel:
	call ClearSprites
	call SaveScreenTilesToBuffer1
	ld a, [wWhichPokemon]
	ld hl, wPartyMon1
	ld bc, wPartyMon2 - wPartyMon1
	call AddNTimes
	call AbilityEnsureMon
	ld [wAbilityID], a
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
	ld a, [wAbilityID]
	call AbilityDrawDescription
	coord hl, 2, 14
	ld de, PartyAbilityHelp
	call PlaceString
.wait
	call DelayFrame
	call JoypadLowSensitivity
	ld a, [hJoy5]
	and A_BUTTON | B_BUTTON | SELECT
	jr z, .wait
	jp LoadScreenTilesFromBuffer1
PartyAbilityHelp:
	db "A/B CLOSE@"

; Do not initialize or alter an unsupported species when using a capsule.
AbilityCapsuleCheck::
	ld a, [wNatureMonPtr]
	ld h, a
	ld a, [wNatureMonPtr + 1]
	ld l, a
	ld a, [hl]
	call AbilityFamily
	ld [wAbilityID], a
	ret

INCLUDE "engine/battle/expanded_abilities.asm"
