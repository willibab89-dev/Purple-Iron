db DEX_UNIQUE_NIDOKING_UNIQUE2 ; pokedex id
db 75 ; base hp
db 95 ; base attack
db 80 ; base defense
db 100 ; base speed
db 70 ; base special
db POISON ; species type 1
db GROUND ; species type 2
db 45 ; catch rate
db 195 ; base exp yield
INCBIN "pic/unique/nidoking_unique2.pic",0,1
dw Unique13PicFront
dw Unique13PicBack
; attacks known at lvl 0
db TACKLE
db LEER
db 0
db 0
db 3 ; growth rate
; learnset
	tmlearn 1,5,6,7
	tmlearn 9,10
	tmlearn 17,18,19,20
	tmlearn 28
	tmlearn 39,40
	tmlearn 44
	tmlearn 50,54
db 0 ; padding
