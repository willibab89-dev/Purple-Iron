db DEX_UNIQUE_NIDORANM_UNIQUE ; pokedex id
db 46 ; base hp
db 57 ; base attack
db 40 ; base defense
db 50 ; base speed
db 40 ; base special
db POISON ; species type 1
db POISON ; species type 2
db 235 ; catch rate
db 60 ; base exp yield
INCBIN "pic/unique/nidoranm_unique.pic",0,1
dw Unique14PicFront
dw Unique14PicBack
; attacks known at lvl 0
db LEER
db TACKLE
db 0
db 0
db 3 ; growth rate
; learnset
	tmlearn 6,7,8
	tmlearn 14
	tmlearn 24
	tmlearn 25
	tmlearn 33,40
	tmlearn 44
	tmlearn 0
db 0 ; padding
