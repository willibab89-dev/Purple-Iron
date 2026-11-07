db DEX_ARCANINE ; pokedex id
db 90 ; base hp
db 110 ; base attack
db 80 ; base defense
db 95 ; base speed
db 80 ; base special
db FIRE ; species type 1
db FIRE ; species type 2
db 75 ; catch rate
db 213 ; base exp yield
INCBIN ARCANINE_FR,0,1 ; 77, sprite dimensions
dw ArcaninePicFront
dw ArcaninePicBack
; attacks known at lvl 0
db BITE
db ROAR
db EMBER
db 0
db 5 ; growth rate
; learnset
	tmlearn 8
	tmlearn 9,15
	tmlearn 23
	tmlearn 28,30,32
	tmlearn 33,38,39,40
	tmlearn 44
	tmlearn 0
db 0 ; padding
