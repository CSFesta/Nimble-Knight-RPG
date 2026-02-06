extends AnimatedSprite2D
class_name GuardTexture

var current_anim := ""

func update_animation(velocity: Vector2) -> void:
	# Flip junto com o corpo
	if velocity.x > 0:
		flip_h = false
	elif velocity.x < 0:
		flip_h = true

	if current_anim == "guard":
		return

	current_anim = "guard"
	play("guard")
