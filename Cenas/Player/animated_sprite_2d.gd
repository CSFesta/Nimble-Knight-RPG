extends AnimatedSprite2D
class_name CharacterTexture

var current_state := "idle"

func update_animation(state: String, velocity: Vector2) -> void:
	# Flip horizontal 
	if velocity.x > 0:
		flip_h = false
	elif velocity.x < 0:
		flip_h = true

	# Evita tocar a mesma animação toda frame
	if current_state == state:
		return

	current_state = state

	match state:
		"idle":
			play("idle")
		"walk":
			play("walk")
		"attack":
			play("attack")
		"strong_attack":
			play("strong_attack")
		"guard":
			play("guard")
