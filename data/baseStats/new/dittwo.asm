db DEX_DITTWO ; pokedex id
db 48 ; base hp
db 48 ; base attack
db 48 ; base defense
db 48 ; base speed
db 48 ; base special
db NORMAL ; species type 1
db NORMAL ; species type 2
db 35 ; catch rate
db 61 ; base exp yield
INCBIN "pic/new_species/dittwo.pic",0,1
dw DittwoPicFront
dw DittwoPicBack
db TRANSFORM
db 0
db 0
db 0
db 0 ; growth rate
	tmlearn 0
	tmlearn 0
	tmlearn 0
	tmlearn 0
	tmlearn 0
	tmlearn 0
	tmlearn 0
db 0 ; padding
