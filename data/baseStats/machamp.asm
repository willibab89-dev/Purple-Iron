db DEX_MACHAMP ; pokedex id
db 90 ; base hp
db 130 ; base attack
db 80 ; base defense
db 55 ; base speed
db 65 ; base special
db FIGHTING ; species type 1
db FIGHTING ; species type 2
db 45 ; catch rate
db 193 ; base exp yield
INCBIN MACHAMP_FR,0,1 ; 77, sprite dimensions
dw MachampPicFront
dw MachampPicBack
; attacks known at lvl 0
db KARATE_CHOP
db LEER
db LOW_KICK
db DOUBLESLAP
db 3 ; growth rate
; learnset
	tmlearn 1,5,8
	tmlearn 10
	tmlearn 17,18,19,20
	tmlearn 26
	tmlearn 34,35,40
	tmlearn 44,48
	tmlearn 54
db 0 ; padding
