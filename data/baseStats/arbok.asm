db DEX_ARBOK ; pokedex id
db 70 ; base hp
db 85 ; base attack
db 69 ; base defense
db 95 ; base speed
db 65 ; base special
db POISON ; species type 1
db POISON ; species type 2
db 90 ; catch rate
db 147 ; base exp yield
INCBIN ARBOK_FR,0,1 ; 77, sprite dimensions
dw ArbokPicFront
dw ArbokPicBack
; attacks known at lvl 0
db LEER
db POISON_STING
db WRAP
db 0
db 0 ; growth rate
; learnset
	tmlearn 6,8
	tmlearn 0
	tmlearn 20,21
	tmlearn 27
	tmlearn 40
	tmlearn 44,48
	tmlearn 50,54
db 0 ; padding
