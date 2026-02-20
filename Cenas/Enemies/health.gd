extends Node

var max_life: int
var life: int

signal died
signal damaged(amount)

func setup(hp: int) -> void:
	max_life = hp
	life = hp

func take_damage(amount: int) -> void:
	life = max(life - amount, 0)
	damaged.emit(amount)
	
	if life == 0:
		died.emit()
