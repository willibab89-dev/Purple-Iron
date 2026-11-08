

;joenote - commenting this all out because yellow's method is now being used
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;LoneMoves:
;; these are used for gym leaders.
;; this is not automatic! you have to write the number you want to wLoneAttackNo
;; first. e.g., erika's script writes 4 to wLoneAttackNo to get mega drain,
;; the fourth entry in the list.
;
;; first byte:  pokemon in the trainer's party that gets the move
;; second byte: move
;; unterminated
;	db 1,BIDE
;	db 1,BUBBLEBEAM
;	db 2,THUNDERBOLT
;	db 2,MEGA_DRAIN
;	db 3,TOXIC
;	db 3,PSYWAVE
;	db 3,FIRE_BLAST
;	db 4,FISSURE
;
;TeamMoves:
;; these are used for elite four.
;; this is automatic, based on trainer class.
;; don't be confused by LoneMoves above, the two data structures are
;	; _completely_ unrelated.
;
;; first byte: trainer (all trainers in this class have this move)
;; second byte: move
;; ff-terminated
;	db LORELEI,BLIZZARD
;	db BRUNO,FISSURE
;	db AGATHA,TOXIC
;	db LANCE,BARRIER
;	db $FF
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; yellow has its own format.

; entry = trainerclass, trainerid, moveset+, 0
; moveset = partymon location, partymon's move, moveid
SpecialTrainerMoves:
	db BROCK,$1
	db 0
	
	db MISTY,$1
	db 2,1,HARDEN
	db 2,2,WATER_GUN
	db 2,3,SWIFT
	db 2,4,BUBBLEBEAM
	db 0
	
	db LT_SURGE,$1
	db 0
	
	db ERIKA,$1
	db 0
	
	db KOGA,$1
	db 1,1,EXPLOSION
	db 3,1,TOXIC
	db 3,2,POISON_GAS
	db 3,3,INCINERATE
	db 3,4,HAZE
	db 0
	
	db SABRINA,$1
	db 1,1,REFLECT
	db 2,1,LIGHT_SCREEN
	db 2,2,PSYBEAM
	db 2,3,SUBSTITUTE
	db 2,4,MIND_BREAK
	db 0
	
	db BLAINE,$1
	db 1,1,SWIFT
	db 2,1,STRENGTH
	db 3,3,TAKE_DOWN
	db 4,2,FIRE_BLAST
	db 0
	
	db GIOVANNI,$3
	db 2,1,FISSURE
	db 3,1,EARTHQUAKE
	db 3,2,POISON_FANG
	db 3,3,THUNDERBOLT
	db 3,4,BULK_UP
	db 6,1,ROCK_SLIDE
	db 6,2,PIERCE
	db 6,3,EARTHQUAKE
	db 6,4,MEGAHORN
	db 0
	
	db LORELEI,$1
	db 1,1,BUBBLEBEAM
	db 3,1,REST
	db 3,2,ICE_BEAM
	db 3,3,PSYCHIC_M
	db 3,4,SURF
	db 4,1,CHARM
	db 4,2,LOVELY_KISS
	db 4,3,FROST_BREATH
	db 4,4,PSYCHIC_M
	db 5,1,CONFUSE_RAY
	db 5,2,ICE_BEAM
	db 5,3,HEAL_BELL
	db 5,4,HYDRO_PUMP
	db 0

	db BRUNO,$1
	db 1,1,ROCK_SLIDE
	db 1,2,SCREECH
	db 1,4,DIG
	db 3,1,ROLLING_KICK
	db 4,1,ROCK_SLIDE
	db 4,2,SCREECH
	db 4,4,EARTHQUAKE
	db 5,1,KARATE_CHOP
	db 5,3,DOUBLE_EDGE
	db 2,1,ICE_PUNCH
	db 2,2,THUNDERPUNCH
	db 2,3,FIRE_PUNCH
	db 2,4,BRICK_BREAK
	db 0

	db AGATHA,$1
	db 1,2,MIMIC
	db 2,1,HYPNOSIS
	db 2,2,DREAM_EATER
	db 2,3,SUBSTITUTE
	db 2,4,THUNDERBOLT
	db 3,1,SCREECH
	db 3,2,POISON_FANG
	db 3,3,SHADOW_LEECH
	db 3,4,TOXIC
	db 4,1,POISON_FANG
	db 4,2,CRUNCH
	db 4,3,SCREECH
	db 4,4,COIL
	db 5,1,CONFUSE_RAY
	db 5,2,CURSE
	db 5,3,SHADOW_LEECH
	db 5,4,PSYCHIC_M
	db 0

	db LANCE,$1
	db 2,1,THUNDER_WAVE
	db 2,3,THUNDERBOLT
	db 3,1,SURF
	db 3,2,BODY_SLAM
	db 3,3,ICE_BEAM
	db 1,1,CRUNCH
	db 1,2,DRAGON_DANCE
	db 1,3,OUTRAGE
	db 1,4,HYPER_BEAM
	db 4,1,ROCK_SLIDE
	db 4,2,CRUNCH
	db 4,3,STONE_EDGE
	db 4,4,SKY_ATTACK
	db 5,1,DRAGON_DANCE
	db 5,2,BODY_SLAM
	db 5,3,WING_ATTACK
	db 5,4,THUNDER
	db 0

	db SONY3,$1
	db 2,1,THUNDER_WAVE
	db 6,1,HYDRO_PUMP
	db 6,2,BLIZZARD
	db 6,3,REFLECT
	db 6,4,SKULL_BASH
	db 1,1,GALE_WIND
	db 1,2,ROOST
	db 1,3,MIRROR_MOVE
	db 1,4,SKY_ATTACK
	db 3,1,MEGAHORN
	db 3,2,EARTHQUAKE
	db 3,3,ROCK_SLIDE
	db 3,4,TAKE_DOWN
	db 4,1,FLAMETHROWER
	db 4,2,REST
	db 4,3,DOUBLE_EDGE
	db 4,4,CRUNCH
	db 5,1,HYPNOSIS
	db 5,2,LEECH_SEED
	db 5,3,PSYCHIC_M
	db 5,4,BARRAGE
	db 0

	db SONY3,$2
	db 2,1,THUNDER_WAVE
	db 6,1,MEGA_DRAIN
	db 1,1,GALE_WIND
	db 1,2,ROOST
	db 1,3,MIRROR_MOVE
	db 1,4,SKY_ATTACK
	db 3,1,MEGAHORN
	db 3,2,EARTHQUAKE
	db 3,3,ROCK_SLIDE
	db 3,4,TAKE_DOWN
	db 4,1,DRAGON_DANCE
	db 4,2,CRUNCH
	db 4,3,HYDRO_PUMP
	db 4,4,OUTRAGE
	db 5,1,FLAMETHROWER
	db 5,2,REST
	db 5,3,DOUBLE_EDGE
	db 5,4,CRUNCH
	db 0

	db SONY3,$3
	db 2,1,THUNDER_WAVE
	db 1,1,GALE_WIND
	db 1,2,ROOST
	db 1,3,MIRROR_MOVE
	db 1,4,SKY_ATTACK
	db 3,1,MEGAHORN
	db 3,2,EARTHQUAKE
	db 3,3,ROCK_SLIDE
	db 3,4,TAKE_DOWN
	db 4,1,HYPNOSIS
	db 4,2,LEECH_SEED
	db 4,3,PSYCHIC_M
	db 4,4,BARRAGE
	db 5,1,DRAGON_DANCE
	db 5,2,CRUNCH
	db 5,3,HYDRO_PUMP
	db 5,4,OUTRAGE
	db 6,1,WING_ATTACK
	db 6,2,FLAMETHROWER
	db 6,3,FIRE_SPIN
	db 6,4,DRAGON_DANCE
	db 0

	;prof oak's 1st pokemon
	db PROF_OAK,$1
	db 1,1,RAGE
	db 1,2,EARTHQUAKE
	db 1,3,FACADE
	db 1,4,DOUBLE_EDGE
	db 0
	db PROF_OAK,$2
	db 1,1,RAGE
	db 1,2,EARTHQUAKE
	db 1,3,FACADE
	db 1,4,DOUBLE_EDGE
	db 0
	db PROF_OAK,$3
	db 1,1,RAGE
	db 1,2,EARTHQUAKE
	db 1,3,FACADE
	db 1,4,DOUBLE_EDGE
	db 0
	
	;mr fuji battle
	db GENTLEMAN,$5
	db 1,1,BONEMERANG
	db 1,2,BODY_SLAM
	db 1,3,SEISMIC_TOSS
	db 1,4,WAILING_CRY
	db 2,1,HYDRO_PUMP
	db 2,2,ICE_BEAM
	db 2,3,REFLECT
	db 2,4,STONE_PRESS
	db 3,1,SWORDS_DANCE
	db 3,2,SURF
	db 3,3,SLASH
	db 3,4,STONE_EDGE
	db 4,1,SKY_ATTACK
	db 4,2,REFLECT
	db 4,3,CRUNCH
	db 4,4,ROCK_SLIDE
	db 5,1,FIRE_BLAST
	db 5,2,BODY_SLAM
	db 5,3,CRUNCH
	db 5,4,REST
	db 0
	
	;Chief battle
	db CHIEF,$1
	db 1,1,BODY_SLAM
	db 1,2,SUBMISSION
	db 1,3,COUNTER
	db 1,4,ICE_BEAM
	db 2,1,EARTHQUAKE
	db 2,2,ROCK_SLIDE
	db 2,3,MEGAHORN
	db 2,4,BULK_UP
	db 3,1,AMNESIA
	db 3,2,SURF
	db 3,3,PSYCHIC_M
	db 3,4,ICE_BEAM
	db 4,1,BULK_UP
	db 4,2,SHELL_BREAK
	db 4,3,SUBMISSION
	db 4,4,BODY_SLAM
	db 5,1,SWORDS_DANCE
	db 5,2,SLASH
	db 5,3,WING_ATTACK
	db 5,4,X_SCISSOR
	db 6,1,FACADE
	db 6,2,DOUBLE_EDGE
	db 6,3,STOMP
	db 6,4,REST
	db 0
	
	;Seiga battle
	db LASS,$13
	db 3,1,SWORDS_DANCE
	db 3,2,RAZOR_LEAF
	db 3,3,SLEEP_POWDER
	db 3,4,BODY_SLAM
	db 1,1,PSYCHIC_M
	db 1,2,SING
	db 1,3,METRONOME
	db 1,4,MOONLIGHT
	db 2,1,THUNDERBOLT
	db 2,2,HYPNOSIS
	db 2,3,DREAM_EATER
	db 2,4,CONFUSE_RAY
	db 4,1,FIRE_BLAST
	db 4,2,REFLECT
	db 4,3,WAILING_CRY
	db 4,4,CONFUSE_RAY
	db 5,1,DIZZY_PUNCH
	db 5,2,COUNTER
	db 5,3,ICE_BEAM
	db 5,4,FACADE
	db 6,1,SNIPE_SHOT
	db 6,2,ICE_BEAM
	db 6,3,SPIKE_CANNON
	db 6,4,REFLECT
	db 0
	
	;Red battle
	db JR_TRAINER_M,$9
	db 1,1,HYDRO_PUMP
	db 1,2,ICE_BEAM
	db 1,3,THUNDERBOLT
	db 1,4,HEAL_BELL
	db 2,1,SLEEP_POWDER
	db 2,2,GROWTH
	db 2,3,PETAL_DANCE
	db 2,4,SLUDGE
	db 3,1,FIRE_BLAST
	db 3,2,WING_ATTACK
	db 3,3,DRAGON_DANCE
	db 3,4,HYPER_BEAM
	db 4,1,HYDRO_PUMP
	db 4,2,ICE_BEAM
	db 4,3,SPIKE_CANNON
	db 4,4,REFLECT
	db 5,1,CRUNCH
	db 5,2,REST
	db 5,3,BODY_SLAM
	db 5,4,EARTHQUAKE
	db 6,1,THUNDER_WAVE
	db 6,2,THUNDER
	db 6,3,THUNDERCLAP
	db 6,4,LIGHT_SCREEN
	db 0
	
	db $ff