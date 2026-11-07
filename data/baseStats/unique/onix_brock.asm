db DEX_UNIQUE_ONIX_BROCK ; pokedex id
db 50 ; base hp
db 60 ; base attack
db 150 ; base defense
db 50 ; base speed
db 40 ; base special
db ROCK ; species type 1
db GROUND ; species type 2
db 45 ; catch rate
db 108 ; base exp yield
INCBIN "pic/unique/onix_brock.pic",0,1
dw Unique16PicFront
dw Unique16PicBack
; attacks known at lvl 0
db TACKLE
db SCREECH
db 0
db 0
db 0 ; growth rate
; learnset
	tmlearn 8
	tmlearn 0
	tmlearn 0
	tmlearn 28
	tmlearn 34
	tmlearn 44,48
	tmlearn 50,54
db 0 ; padding
