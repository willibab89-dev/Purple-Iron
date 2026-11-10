db DEX_AERODACTYL ; pokedex id
db 80 ; base hp
db 105 ; base attack
db 65 ; base defense
db 130 ; base speed
db 60 ; base special
db ROCK ; species type 1
db FLYING ; species type 2
db 45 ; catch rate
db 202 ; base exp yield
INCBIN AERODACTYL_FR,0,1 ; 77, sprite dimensions
dw AerodactylPicFront
dw AerodactylPicBack
; attacks known at lvl 0
db WING_ATTACK
db BITE
db TAKE_DOWN
db 0
db 5 ; growth rate
; learnset
	tmlearn 0
	tmlearn 0
	tmlearn 20
	tmlearn 32
	tmlearn 33,39
	tmlearn 43,44,48
	tmlearn 52
db 0 ; padding
