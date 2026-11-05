SECTION "Move animation mapping", ROMX, BANK[$34]

; Called only by move-specific presentation paths, never raw animation paths.
; Keep the move record's first byte as the real ID for all battle logic.
MapMoveAnimation:
	push hl
	push bc
	ld a, [wAnimationID]
	and a
	jr z, .done
	cp MAX_MOVE_ID + 1
	jr nc, .invalid
	dec a
	ld c, a
	ld b, 0
	ld hl, MoveAnimationMap
	add hl, bc
	ld a, [hl]
	ld [wAnimationID], a
	jr .done
.invalid
	xor a
	ld [wAnimationID], a
.done
	pop bc
	pop hl
	ret

MoveAnimationMap:
	db 1
	db 2
	db 3
	db 4
	db 5
	db 6
	db 7
	db 8
	db 9
	db 10
	db 11
	db 12
	db 13
	db 14
	db 15
	db 16
	db 17
	db 18
	db 19
	db 20
	db 21
	db 22
	db 23
	db 24
	db 25
	db 26
	db 27
	db 28
	db 29
	db 30
	db 31
	db 32
	db 33
	db 34
	db 35
	db 36
	db 37
	db 38
	db 39
	db 40
	db 41
	db 42
	db 43
	db 44
	db 45
	db 46
	db 47
	db 48
	db 49
	db 50
	db 51
	db 52
	db 53
	db 54
	db 55
	db 56
	db 57
	db 58
	db 59
	db 60
	db 61
	db 62
	db 63
	db 64
	db 65
	db 66
	db 67
	db 68
	db 69
	db 70
	db 71
	db 72
	db 73
	db 74
	db 75
	db 76
	db 77
	db 78
	db 79
	db 80
	db 81
	db 82
	db 83
	db 84
	db 85
	db 86
	db 87
	db 88
	db 89
	db 90
	db 91
	db 92
	db 93
	db 94
	db 95
	db 96
	db 97
	db 98
	db 99
	db 100
	db 101
	db 102
	db 103
	db 104
	db 105
	db 106
	db 107
	db 108
	db 109
	db 110
	db 111
	db 112
	db 113
	db 114
	db 115
	db 116
	db 117
	db 118
	db 119
	db 120
	db 121
	db 122
	db 123
	db 124
	db 125
	db 126
	db 127
	db 128
	db 129
	db 130
	db 131
	db 132
	db 133
	db 134
	db 135
	db 136
	db 137
	db 138
	db 139
	db 140
	db 141
	db 142
	db 143
	db 144
	db 145
	db 146
	db 147
	db 148
	db 149
	db 150
	db 151
	db 152
	db 153
	db 154
	db 155
	db 156
	db 157
	db 158
	db 159
	db 160
	db 161
	db 162
	db 163
	db 164
	db 165
	db MEGA_DRAIN ; GIGA_DRAIN
	db RECOVER ; SYNTHESIS
	db HORN_ATTACK ; MEGAHORN
	db SLASH ; X_SCISSOR
	db LICK ; ASTONISH
	db MEGA_PUNCH ; DRAIN_PUNCH
	db ROCK_THROW ; STONE_EDGE
	db AGILITY ; ROCK_POLISH
	db BARRIER ; ICE_ARMOR
	db RECOVER ; ROOST
	db BODY_SLAM ; FACADE
	db THRASH ; FLAIL
	db BUBBLEBEAM ; BRINE
	db EMBER ; INCINERATE
	db SLUDGE ; VENOSHOCK
	db SMOG ; POLLUTION
	db NIGHT_SHADE ; PUNISHMENT
	db THUNDERSHOCK ; SHOCK_WAVE
	db POISON_STING ; POISON_TAIL
	db AURORA_BEAM ; FROST_BREATH
	db ICE_BEAM ; ICE_SHARD
	db HORN_ATTACK ; PIERCE
	db ROCK_THROW ; STONE_PRESS
	db PSYBEAM ; PSYSHOCK
	db WATER_GUN ; SNIPE_SHOT
	db WING_ATTACK ; AERIAL_ACE
	db LICK ; TONGUE_LASH
	db HARDEN ; STOCKPILE
	db LEECH_LIFE ; LUNGE
	db VICEGRIP ; SHELL_BREAK
	db NIGHT_SHADE ; WAILING_CRY
	db MEDITATE ; PSYCH_UP
	db PSYCHIC_M ; MIND_BREAK
	db MEDITATE ; BULK_UP
	db KARATE_CHOP ; BRICK_BREAK
	db ROCK_THROW ; ROCK_TOMB
	db EMBER ; WILL_O_WISP
	db EMBER ; FLAME_CHARGE
	db RECOVER ; CAUTERIZE
	db BUBBLEBEAM ; SCALD
	db FOCUS_ENERGY ; CHARGE
	db AURORA_BEAM ; ICY_WIND
	db ICE_BEAM ; FLASH_FREEZE
	db GUST ; GALE_WIND
	db DEFENSE_CURL ; COIL
	db BITE ; POISON_FANG
	db AGILITY ; DRAGON_DANCE
MoveAnimationMapEnd:

; The legacy name routine treated every high ID as a TM/HM item. Check the
; list type first so future moves 196..254 retain their names and IDs.
ClassifyMachineName:
	ld a, [wNameListType]
	cp ITEM_NAME
	ret nz
	ld a, [wd0b5]
	cp HM_01
	ret c
	sub $C3
	ld [wd0b5], a
	ld a, TMHM_NAME
	ld [wNameListType], a
	ret
