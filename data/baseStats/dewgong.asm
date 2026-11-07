db DEX_DEWGONG ; pokedex id
db 90 ; base hp
db 70 ; base attack
db 80 ; base defense
db 70 ; base speed
db 95 ; base special
db WATER ; species type 1
db ICE ; species type 2
db 75 ; catch rate
db 176 ; base exp yield
INCBIN DEWGONG_FR,0,1 ; 66, sprite dimensions
dw DewgongPicFront
dw DewgongPicBack
; attacks known at lvl 0
db HEADBUTT
db GROWL
db WATER_GUN
db 0
db 0 ; growth rate
; learnset
	tmlearn 7,8
	tmlearn 9,11,12,13,14,15,16
	tmlearn 0
	tmlearn 0
	tmlearn 40
	tmlearn 44
	tmlearn 53,54
db 0 ; padding
