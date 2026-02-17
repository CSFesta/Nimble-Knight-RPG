extends Area2D

# Variável para evitar múltiplos danos no mesmo frame físico
var last_attack_time := 0.0

func _ready() -> void:
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	var body = get_parent()
	
	if body and body.has_method("take_damage"):
		if body.is_in_group("player"):
			if area.is_in_group("enemy_attack"):
				# Proteção extra contra double-click de colisão
				var current_time = Time.get_ticks_msec()
				if current_time - last_attack_time < 100:
					return
				last_attack_time = current_time

				var damage_to_apply = area.damage if "damage" in area else 1
				
				# APLICA O DANO (Apenas uma vez!)
				body.take_damage(damage_to_apply)
				
				# LOG DE DANO
				print("💥 PLAYER ATINGIDO! Vida atual: ", body.health.life)
				
				# A linha extra que estava aqui foi removida.
