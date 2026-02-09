extends Area2D

func _ready() -> void:
	connect("area_entered", _on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if not area.is_in_group("player_attack"):
		return

	print("Goblin levou dano")

	var goblin = get_parent()
	goblin.take_damage(area.damage)
