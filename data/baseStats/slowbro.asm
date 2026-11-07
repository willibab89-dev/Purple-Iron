db DEX_SLOWBRO ; pokedex id
db 95 ; base hp
db 75 ; base attack
db 110 ; base defense
db 30 ; base speed
db 80 ; base special
db WATER ; species type 1
db PSYCHIC ; species type 2
db 75 ; catch rate
db 164 ; base exp yield
INCBIN SLOWBRO_FR,0,1 ; 77, sprite dimensions
dw SlowbroPicFront
dw SlowbroPicBack
; attacks known at lvl 0
db CONFUSION
db GROWL
db WATER_GUN
db 0
db 0 ; growth rate
; learnset
	tmlearn 8
	tmlearn 11,12,13,14,16
	tmlearn 18,19
	tmlearn 29,30
	tmlearn 33,34,39,40
	tmlearn 44,45,46
	tmlearn 49,53,54,55
db 0 ; padding
