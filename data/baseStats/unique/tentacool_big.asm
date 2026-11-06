db DEX_UNIQUE_TENTACOOL_BIG ; pokedex id
db 40 ; base hp
db 40 ; base attack
db 35 ; base defense
db 70 ; base speed
db 100 ; base special
db WATER ; species type 1
db POISON ; species type 2
db 60 ; catch rate
db 105 ; base exp yield
INCBIN "pic/unique/tentacool_big.pic",0,1
dw Unique20PicFront
dw Unique20PicBack
; attacks known at lvl 0
db ACID
db 0
db 0
db 0
db 5 ; growth rate
; learnset
	tmlearn 3,6
	tmlearn 11,12,13,14
	tmlearn 21
	tmlearn 32
	tmlearn 33,40
	tmlearn 44
	tmlearn 51,53
db 0 ; padding
