db DEX_HITMONCHAN ; pokedex id
db 60 ; base hp
db 105 ; base attack
db 79 ; base defense
db 76 ; base speed
db 70 ; base special
db FIGHTING ; species type 1
db FIGHTING ; species type 2
db 45 ; catch rate
db 140 ; base exp yield
INCBIN HITMONCHAN_FR,0,1 ; 66, sprite dimensions
dw HitmonchanPicFront
dw HitmonchanPicBack
; attacks known at lvl 0
db MEGA_PUNCH
db COMET_PUNCH
db 0
db 0
db 0 ; growth rate
; learnset
	tmlearn 1,8
	tmlearn 0
	tmlearn 18,19
	tmlearn 0
	tmlearn 35,39,40
	tmlearn 44
	tmlearn 54
db 0 ; padding
