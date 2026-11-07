db DEX_SLOWPOKE ; pokedex id
db 90 ; base hp
db 65 ; base attack
db 65 ; base defense
db 15 ; base speed
db 40 ; base special
db WATER ; species type 1
db PSYCHIC ; species type 2
db 190 ; catch rate
db 99 ; base exp yield
INCBIN SLOWPOKE_FR,0,1 ; 55, sprite dimensions
dw SlowpokePicFront
dw SlowpokePicBack
; attacks known at lvl 0
db CONFUSION
db GROWL
db 0
db 0
db 0 ; growth rate
; learnset
	tmlearn 8
	tmlearn 11,12,13,14,16
	tmlearn 0
	tmlearn 29,30
	tmlearn 33,34,39,40
	tmlearn 44,45,46
	tmlearn 49,53,54,55
db 0 ; padding
