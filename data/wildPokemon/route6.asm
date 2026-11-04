Route6Mons:;joenote - added squirtle
	db $0F
	IF DEF(_RED)
		db 13,ODDISH
		db 13,PIDGEY
		db 15,PIDGEY
		db 12,MANKEY
		db 15,ODDISH
		db 16,ODDISH
		db 16,PIDGEY
		db 14,MANKEY
		db 16,MANKEY
		db 12,UNIQUE_SQUIRTLE_UNIQUE ; rare unique species
	ENDC
	IF DEF(_BLUE)
		db 13,BELLSPROUT
		db 13,PIDGEY
		db 15,PIDGEY
		db 12,MEOWTH
		db 15,BELLSPROUT
		db 16,BELLSPROUT
		db 16,PIDGEY
		db 14,MEOWTH
		db 16,MEOWTH
		db 12,UNIQUE_SQUIRTLE_UNIQUE ; rare unique species
	ENDC
	db $00
