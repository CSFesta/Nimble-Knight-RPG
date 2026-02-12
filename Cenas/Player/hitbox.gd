extends Area2D

@export var damage := 2

func _ready() -> void:
	add_to_group("player_attack")
	monitoring = false
