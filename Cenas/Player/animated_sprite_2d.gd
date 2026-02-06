extends AnimatedSprite2D
class_name BodyTexture

var current_anim := ""

func update_animation(state: String, velocity: Vector2) -> void:
	# Flip horizontal
	if velocity.x > 0:
		flip_h = false
	elif velocity.x < 0:
		flip_h = true

	var next_anim := ""

	match state:
		"idle":
			next_anim = "idle"
		"walk":
			next_anim = "walk"
		"guard":
			next_anim = "guard"
		"attack":
			next_anim = "attack"
		"strong_attack":
			next_anim = "strong_attack"
		_:
			next_anim = "idle"

	if current_anim == next_anim:
		return

	current_anim = next_anim
	play(current_anim)
