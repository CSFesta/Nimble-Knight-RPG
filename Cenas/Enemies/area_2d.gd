extends Area2D

func _ready() -> void:
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	var body = get_parent()
	
	if body and body.has_method("take_damage"):
		# Verifica se quem está recebendo o dano é o Player
		if body.is_in_group("player"):
			# Verifica se quem atacou é do grupo inimigo
			if area.is_in_group("enemy_attack"):
				var damage_to_apply = area.damage if "damage" in area else 1
				
				# --- LOG DE DANO ---
				body.take_damage(damage_to_apply)
				print("💥 PLAYER ATINGIDO! Vida atual: ", body.health.life)
				body.take_damage(damage_to_apply)
