db DEX_UNIQUE_NIDOKING_UNIQUE ; pokedex id
db 90 ; base hp
db 110 ; base attack
db 95 ; base defense
db 65 ; base speed
db 65 ; base special
db POISON ; species type 1
db GROUND ; species type 2
db 45 ; catch rate
db 195 ; base exp yield
INCBIN "pic/unique/nidoking_unique.pic",0,1
dw Unique12PicFront
dw Unique12PicBack
; attacks known at lvl 0
db TACKLE
db LEER
db 0
db 0
db 3 ; growth rate
; learnset
	tmlearn 1,5,6,7,8
	tmlearn 9,10
	tmlearn 17,18,19,20
	tmlearn 26,28
	tmlearn 40
	tmlearn 44,48
	tmlearn 50,54
db 0 ; padding
