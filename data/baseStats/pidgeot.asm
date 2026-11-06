db DEX_PIDGEOT ; pokedex id
db 90 ; base hp
db 80 ; base attack
db 85 ; base defense
db 91 ; base speed
db 70 ; base special
db NORMAL ; species type 1
db FLYING ; species type 2
db 45 ; catch rate
db 172 ; base exp yield
INCBIN PIDGEOT_FR,0,1 ; 77, sprite dimensions
dw PidgeotPicFront
dw PidgeotPicBack
; attacks known at lvl 0
db GUST
db SAND_ATTACK
db QUICK_ATTACK
db 0
db 3 ; growth rate
; learnset
	tmlearn 4
	tmlearn 0
	tmlearn 0
	tmlearn 32
	tmlearn 33,39
	tmlearn 43,44
	tmlearn 52
db 0 ; padding
