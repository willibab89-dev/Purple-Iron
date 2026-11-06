db DEX_GOLBAT ; pokedex id
db 75 ; base hp
db 80 ; base attack
db 70 ; base defense
db 90 ; base speed
db 75 ; base special
db POISON ; species type 1
db FLYING ; species type 2
db 90 ; catch rate
db 171 ; base exp yield
INCBIN GOLBAT_FR,0,1 ; 77, sprite dimensions
dw GolbatPicFront
dw GolbatPicBack
; attacks known at lvl 0
db LEECH_LIFE
db SCREECH
db BITE
db 0
db 0 ; growth rate
; learnset
	tmlearn 2,4,6
	tmlearn 15
	tmlearn 21
	tmlearn 32
	tmlearn 39
	tmlearn 44
	tmlearn 0
db 0 ; padding
