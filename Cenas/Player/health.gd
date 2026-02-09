extends Node

@export var max_life: int = 10
var life: int

signal died
signal damaged(amount)

func _ready() -> void:
	life = max_life

func take_damage(amount: int) -> void:
	life = max(life - amount, 0)
	damaged.emit(amount)

	if life == 0:
		die()

func die() -> void:
	died.emit()
