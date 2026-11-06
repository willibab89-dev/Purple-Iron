db DEX_UNIQUE_MAROWAK_UNIQUE ; pokedex id
db 60 ; base hp
db 80 ; base attack
db 110 ; base defense
db 45 ; base speed
db 50 ; base special
db GROUND ; species type 1
db GROUND ; species type 2
db 75 ; catch rate
db 124 ; base exp yield
INCBIN "pic/unique/marowak_unique.pic",0,1
dw Unique11PicFront
dw Unique11PicBack
; attacks known at lvl 0
db BONE_CLUB
db GROWL
db LEER
db FOCUS_ENERGY
db 0 ; growth rate
; learnset
	tmlearn 1,5,8
	tmlearn 11,12,13,14,15
	tmlearn 17,18,19
	tmlearn 26,27,28
	tmlearn 34,38,40
	tmlearn 44
	tmlearn 54
db 0 ; padding
