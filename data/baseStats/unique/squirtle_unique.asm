db DEX_UNIQUE_SQUIRTLE_UNIQUE ; pokedex id
db 74 ; base hp
db 78 ; base attack
db 95 ; base defense
db 73 ; base speed
db 80 ; base special
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
db WITHDRAW
db 0
db 3 ; growth rate
; learnset
	tmlearn 1,8
	tmlearn 0
	tmlearn 18,19
	tmlearn 0
	tmlearn 33
	tmlearn 44
	tmlearn 50,53,54
db 0 ; padding
