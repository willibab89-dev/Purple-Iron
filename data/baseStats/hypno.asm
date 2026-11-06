db DEX_HYPNO ; pokedex id
db 85 ; base hp
db 73 ; base attack
db 70 ; base defense
db 67 ; base speed
db 115 ; base special
db PSYCHIC ; species type 1
db GROUND ; species type 2
db 75 ; catch rate
db 165 ; base exp yield
INCBIN HYPNO_FR,0,1 ; 77, sprite dimensions
dw HypnoPicFront
dw HypnoPicBack
; attacks known at lvl 0
db POUND
db HYPNOSIS
db DISABLE
db CONFUSION
db 0 ; growth rate
; learnset
	tmlearn 1,5,8
	tmlearn 15
	tmlearn 17,18,19
	tmlearn 29,30,31
	tmlearn 33,35,40
	tmlearn 42,44,45,46
	tmlearn 49,50,55
db 0 ; padding
