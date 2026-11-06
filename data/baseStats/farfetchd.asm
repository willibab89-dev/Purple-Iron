db DEX_FARFETCHD ; pokedex id
db 62 ; base hp
db 85 ; base attack
db 55 ; base defense
db 87 ; base speed
db 58 ; base special
db NORMAL ; species type 1
db FLYING ; species type 2
db 45 ; catch rate
db 94 ; base exp yield
INCBIN FARFETCHD_FR,0,1 ; 66, sprite dimensions
dw FarfetchdPicFront
dw FarfetchdPicBack
; attacks known at lvl 0
db PECK
db SAND_ATTACK
db 0
db 0
db 0 ; growth rate
; learnset
	tmlearn 2,3,4,8
	tmlearn 0
	tmlearn 0
	tmlearn 32
	tmlearn 33,39,40
	tmlearn 44
	tmlearn 51,52
db 0 ; padding
