db DEX_MAGNETON ; pokedex id
db 50 ; base hp
db 60 ; base attack
db 95 ; base defense
db 70 ; base speed
db 120 ; base special
db ELECTRIC ; species type 1
db ELECTRIC ; species type 2
db 60 ; catch rate
db 161 ; base exp yield
INCBIN MAGNETON_FR,0,1 ; 66, sprite dimensions
dw MagnetonPicFront
dw MagnetonPicBack
; attacks known at lvl 0
db TACKLE
db THUNDERSHOCK
db SUPERSONIC
db 0
db 0 ; growth rate
; learnset
	tmlearn 0
	tmlearn 15
	tmlearn 24
	tmlearn 25,30
	tmlearn 33,39
	tmlearn 44,45
	tmlearn 55
db 0 ; padding
