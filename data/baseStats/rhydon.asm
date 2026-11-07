db DEX_RHYDON ; pokedex id
db 105 ; base hp
db 130 ; base attack
db 120 ; base defense
db 40 ; base speed
db 45 ; base special
db GROUND ; species type 1
db GROUND ; species type 2
db 60 ; catch rate
db 204 ; base exp yield
INCBIN RHYDON_FR,0,1 ; 77, sprite dimensions
dw RhydonPicFront
dw RhydonPicBack
; attacks known at lvl 0
db HORN_ATTACK
db TAIL_WHIP
db STOMP
db 0
db 5 ; growth rate
; learnset
	tmlearn 1,5,7,8
	tmlearn 9,10,16
	tmlearn 17,18,19,20
	tmlearn 26,28
	tmlearn 34,40
	tmlearn 44,48
	tmlearn 54
db 0 ; padding
