db DEX_UNIQUE_TENTACOOL_BIG ; pokedex id
db 100 ; base hp
db 60 ; base attack
db 75 ; base defense
db 40 ; base speed
db 105 ; base special
db WATER ; species type 1
db POISON ; species type 2
db 60 ; catch rate
db 105 ; base exp yield
INCBIN "pic/unique/tentacool_big.pic",0,1
dw Unique20PicFront
dw Unique20PicBack
; attacks known at lvl 0
db POISON_STING
db WATER_GUN
db 0
db 0
db 5 ; growth rate
; learnset
	tmlearn 6
	tmlearn 11,12,13
	tmlearn 0
	tmlearn 0
	tmlearn 33
	tmlearn 44
	tmlearn 50,53
db 0 ; padding
