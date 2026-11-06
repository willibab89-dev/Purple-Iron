db DEX_RAICHU ; pokedex id
db 60 ; base hp
db 90 ; base attack
db 55 ; base defense
db 110 ; base speed
db 90 ; base special
db ELECTRIC ; species type 1
db ELECTRIC ; species type 2
db 75 ; catch rate
db 122 ; base exp yield
INCBIN RAICHU_FR,0,1 ; 77, sprite dimensions
dw RaichuPicFront
dw RaichuPicBack
; attacks known at lvl 0
db THUNDERSHOCK
db GROWL
db TAIL_WHIP
db THUNDER_WAVE
db 0 ; growth rate
; learnset
	tmlearn 1,5,8
	tmlearn 16
	tmlearn 24
	tmlearn 25,32
	tmlearn 33,39,40
	tmlearn 44,45
	tmlearn 55
db 0 ; padding
