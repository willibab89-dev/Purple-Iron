db DEX_TAUROS ; pokedex id
db 75 ; base hp
db 100 ; base attack
db 95 ; base defense
db 110 ; base speed
db 70 ; base special
db NORMAL ; species type 1
db NORMAL ; species type 2
db 45 ; catch rate
db 211 ; base exp yield
INCBIN TAUROS_FR,0,1 ; 77, sprite dimensions
dw TaurosPicFront
dw TaurosPicBack
; attacks known at lvl 0
db TACKLE
db TAIL_WHIP
db 0
db 0
db 5 ; growth rate
; learnset
	tmlearn 8
	tmlearn 9,10
	tmlearn 20
	tmlearn 26,32
	tmlearn 40
	tmlearn 44
	tmlearn 54
db 0 ; padding
