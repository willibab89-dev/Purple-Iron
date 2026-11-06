db DEX_UNIQUE_SQUIRTLE_UNIQUE ; pokedex id
db 44 ; base hp
db 48 ; base attack
db 65 ; base defense
db 43 ; base speed
db 50 ; base special
db WATER ; species type 1
db WATER ; species type 2
db 45 ; catch rate
db 66 ; base exp yield
INCBIN "pic/unique/squirtle_unique.pic",0,1
dw Unique18PicFront
dw Unique18PicBack
; attacks known at lvl 0
db TACKLE
db TAIL_WHIP
db 0
db 0
db 3 ; growth rate
; learnset
	tmlearn 1,5,8
	tmlearn 9,11,12,13,14
	tmlearn 17,18,19
	tmlearn 28
	tmlearn 33,34,40
	tmlearn 44
	tmlearn 53,54
db 0 ; padding
