db DEX_UNIQUE_NIDORANM_UNIQUE ; pokedex id
db 76 ; base hp
db 77 ; base attack
db 80 ; base defense
db 65 ; base speed
db 65 ; base special
db POISON ; species type 1
db POISON ; species type 2
db 235 ; catch rate
db 60 ; base exp yield
INCBIN "pic/unique/nidoranm_unique.pic",0,1
dw Unique14PicFront
dw Unique14PicBack
; attacks known at lvl 0
db TACKLE
db LEER
db 0
db 0
db 3 ; growth rate
; learnset
	tmlearn 6,8
	tmlearn 10
	tmlearn 20
	tmlearn 0
	tmlearn 33
	tmlearn 44
	tmlearn 50
db 0 ; padding
