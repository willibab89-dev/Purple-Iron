db DEX_UNIQUE_MAROWAK_UNIQUE ; pokedex id
db 75 ; base hp
db 110 ; base attack
db 95 ; base defense
db 60 ; base speed
db 45 ; base special
db GROUND ; species type 1
db FIGHTING ; species type 2
db 75 ; catch rate
db 124 ; base exp yield
INCBIN "pic/unique/marowak_unique.pic",0,1
dw Unique11PicFront
dw Unique11PicBack
; attacks known at lvl 0
db BONE_CLUB
db GROWL
db 0
db 0
db 0 ; growth rate
; learnset
	tmlearn 1,5,8
	tmlearn 9,10
	tmlearn 17,18,19,20
	tmlearn 28
	tmlearn 40
	tmlearn 44
	tmlearn 50,54
db 0 ; padding
