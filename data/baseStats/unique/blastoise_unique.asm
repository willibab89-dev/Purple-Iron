db DEX_UNIQUE_BLASTOISE_UNIQUE ; pokedex id
db 89 ; base hp
db 83 ; base attack
db 100 ; base defense
db 58 ; base speed
db 105 ; base special
db WATER ; species type 1
db WATER ; species type 2
db 45 ; catch rate
db 210 ; base exp yield
INCBIN "pic/unique/blastoise_unique.pic",0,1
dw Unique1PicFront
dw Unique1PicBack
; attacks known at lvl 0
db TACKLE
db TAIL_WHIP
db WATER_GUN
db WITHDRAW
db 3 ; growth rate
; learnset
	tmlearn 1,5,8
	tmlearn 9,11,12,13,14,15
	tmlearn 17,18,19
	tmlearn 0
	tmlearn 33,34,40
	tmlearn 44
	tmlearn 53,54
db 0 ; padding
