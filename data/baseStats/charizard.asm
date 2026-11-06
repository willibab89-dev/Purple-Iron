db DEX_CHARIZARD ; pokedex id
db 78 ; base hp
db 94 ; base attack
db 78 ; base defense
db 100 ; base speed
db 85 ; base special
db FIRE ; species type 1
db FLYING ; species type 2
db 45 ; catch rate
db 209 ; base exp yield
INCBIN CHARIZARD_FR,0,1 ; 77, sprite dimensions
dw CharizardPicFront
dw CharizardPicBack
; attacks known at lvl 0
db SCRATCH
db GROWL
db EMBER
db LEER
db 3 ; growth rate
; learnset
	tmlearn 1,3,5,8
	tmlearn 15
	tmlearn 17,18,19,20,23
	tmlearn 32
	tmlearn 33,38,39,40
	tmlearn 44
	tmlearn 51,52,54
db 0 ; padding
