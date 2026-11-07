db DEX_NIDOQUEEN ; pokedex id
db 100 ; base hp
db 82 ; base attack
db 95 ; base defense
db 76 ; base speed
db 75 ; base special
db POISON ; species type 1
db GROUND ; species type 2
db 45 ; catch rate
db 194 ; base exp yield
INCBIN NIDOQUEEN_FR,0,1 ; 77, sprite dimensions
dw NidoqueenPicFront
dw NidoqueenPicBack
; attacks known at lvl 0
db GROWL
db TACKLE
db DOUBLE_KICK
db POISON_STING
db 3 ; growth rate
; learnset
	tmlearn 1,5,6,8
	tmlearn 9,13,14,16
	tmlearn 17,18,19,24
	tmlearn 26,27
	tmlearn 33,38,40
	tmlearn 44,48
	tmlearn 54
db 0 ; padding
