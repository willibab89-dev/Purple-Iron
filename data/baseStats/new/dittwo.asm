db DEX_DITTWO ; pokedex id
db 132 ; base hp
db 33 ; base attack
db 66 ; base defense
db 33 ; base speed
db 66 ; base special
db NORMAL ; species type 1
db NORMAL ; species type 2
db 35 ; catch rate
db 61 ; base exp yield
INCBIN "pic/new_species/dittwo.pic",0,1
dw DittwoPicFront
dw DittwoPicBack
; attacks known at lvl 0
db DUPLICATE
db 0
db 0
db 0
db 0 ; growth rate
	tmlearn 8
	tmlearn 11
	tmlearn 0
	tmlearn 0
	tmlearn 0
	tmlearn 44
	tmlearn 50
db 0 ; padding
