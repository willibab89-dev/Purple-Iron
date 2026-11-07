db DEX_UNIQUE_OMANYTE_UNIQUE ; pokedex id
db 65 ; base hp
db 55 ; base attack
db 110 ; base defense
db 40 ; base speed
db 95 ; base special
db ROCK ; species type 1
db WATER ; species type 2
db 45 ; catch rate
db 120 ; base exp yield
INCBIN "pic/unique/omanyte_unique.pic",0,1
dw Unique15PicFront
dw Unique15PicBack
; attacks known at lvl 0
db WATER_GUN
db WITHDRAW
db 0
db 0
db 0 ; growth rate
; learnset
	tmlearn 0
	tmlearn 11,12,13
	tmlearn 0
	tmlearn 0
	tmlearn 33,34
	tmlearn 44
	tmlearn 50,53
db 0 ; padding
