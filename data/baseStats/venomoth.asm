db DEX_VENOMOTH ; pokedex id
db 70 ; base hp
db 65 ; base attack
db 60 ; base defense
db 90 ; base speed
db 90 ; base special
db BUG ; species type 1
db POISON ; species type 2
db 75 ; catch rate
db 138 ; base exp yield
INCBIN VENOMOTH_FR,0,1 ; 77, sprite dimensions
dw VenomothPicFront
dw VenomothPicBack
; attacks known at lvl 0
db TACKLE
db DISABLE
db CONFUSION
db POISONPOWDER
db 0 ; growth rate
; learnset;joenote-added strength from yellow
	tmlearn 6
	tmlearn 0
	tmlearn 0
	tmlearn 29,30,32
	tmlearn 33,39
	tmlearn 44,46
	tmlearn 54
db 0 ; padding
