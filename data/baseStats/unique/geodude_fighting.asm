db DEX_UNIQUE_GEODUDE_FIGHTING ; pokedex id
db 40 ; base hp
db 80 ; base attack
db 100 ; base defense
db 20 ; base speed
db 30 ; base special
db FIGHTING ; species type 1
db FIGHTING ; species type 2
db 255 ; catch rate
db 86 ; base exp yield
INCBIN "pic/unique/geodude_fighting.pic",0,1
dw Unique6PicFront
dw Unique6PicBack
; attacks known at lvl 0
db TACKLE
db 0
db 0
db 0
db 3 ; growth rate
; learnset
	tmlearn 1,8
	tmlearn 9
	tmlearn 17,18,19
	tmlearn 26,27,28
	tmlearn 34,35,36,38
	tmlearn 44,47,48
	tmlearn 54
db 0 ; padding
