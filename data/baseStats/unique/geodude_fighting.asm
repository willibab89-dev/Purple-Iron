db DEX_UNIQUE_GEODUDE_FIGHTING ; pokedex id
db 70 ; base hp
db 105 ; base attack
db 100 ; base defense
db 35 ; base speed
db 45 ; base special
db FIGHTING ; species type 1
db FIGHTING ; species type 2
db 255 ; catch rate
db 86 ; base exp yield
INCBIN "pic/unique/geodude_fighting.pic",0,1
dw Unique6PicFront
dw Unique6PicBack
; attacks known at lvl 0
db TACKLE
db HARDEN
db 0
db 0
db 3 ; growth rate
; learnset
	tmlearn 1,8
	tmlearn 9,10
	tmlearn 17,18,19,20
	tmlearn 0
	tmlearn 0
	tmlearn 44,48
	tmlearn 50,54
db 0 ; padding
