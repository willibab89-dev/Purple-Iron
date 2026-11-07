db DEX_UNIQUE_RAICHU_UNIQUE ; pokedex id
db 70 ; base hp
db 100 ; base attack
db 70 ; base defense
db 85 ; base speed
db 85 ; base special
db ELECTRIC ; species type 1
db ELECTRIC ; species type 2
db 75 ; catch rate
db 122 ; base exp yield
INCBIN "pic/unique/raichu_unique.pic",0,1
dw Unique17PicFront
dw Unique17PicBack
; attacks known at lvl 0
db THUNDERSHOCK
db GROWL
db 0
db 0
db 0 ; growth rate
; learnset
	tmlearn 1,5,8
	tmlearn 0
	tmlearn 18,19,24
	tmlearn 25
	tmlearn 33,39
	tmlearn 44,45
	tmlearn 50,55
db 0 ; padding
