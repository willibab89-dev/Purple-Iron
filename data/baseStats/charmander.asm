db DEX_CHARMANDER ; pokedex id
db 39 ; base hp
db 52 ; base attack
db 43 ; base defense
db 65 ; base speed
db 50 ; base special
db FIRE ; species type 1
db FIRE ; species type 2
db 45 ; catch rate
db 65 ; base exp yield
INCBIN CHARMANDER_FR,0,1 ; 55, sprite dimensions
dw CharmanderPicFront
dw CharmanderPicBack
; attacks known at lvl 0
db SCRATCH
db GROWL
db 0
db 0
db 3 ; growth rate
; learnset
	tmlearn 1,3,5,8
	tmlearn 0
	tmlearn 17,18,19,20,23
	tmlearn 32
	tmlearn 33,38,39,40
	tmlearn 44
	tmlearn 51,54
db 0 ; padding
