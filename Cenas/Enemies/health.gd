extends Node

@export var max_life: int = 10
var life: int

signal died
signal damaged(amount)

func _ready() -> void:
	life = max_life

func take_damage(amount: int) -> void:
	print("Health.take_damage chamado | Dano:", amount, " | Vida antes:", life)

	life = max(life - amount, 0)
	damaged.emit(amount)

	print("Vida depois:", life)

	if life == 0:
		print("Health.die emitido")
		die()


func die() -> void:
	died.emit()
