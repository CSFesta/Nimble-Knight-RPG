extends CharacterBody2D

@export var speed: float = 40.0
var player: Node2D = null 
@onready var sprite = $AnimatedSprite2D 

var last_direction = "front"

# DICIONÁRIO CORRIGIDO:
# Vector2.LEFT (-1, 0) agora mapeia corretamente para "left"
var directions = {
	Vector2.DOWN: "front",
	Vector2.UP: "back",
	Vector2.LEFT: "left",   # Se continuar trocado, inverta estas duas strings:
	Vector2.RIGHT: "right"  # Troque "left" por "right" aqui se necessário
}

func _physics_process(_delta: float) -> void:
	if is_instance_valid(player):
		var move_dir = (player.global_position - global_position).normalized()
		velocity = move_dir * speed
		move_and_slide()
		update_sprite_animation(move_dir)
	else:
		player = get_tree().get_first_node_in_group("player")
		velocity = Vector2.ZERO
		sprite.play("idle_" + last_direction)

func update_sprite_animation(dir: Vector2) -> void:
	if dir.length() > 0.1:
		var best_match = last_direction
		var max_dot = -2.0 # Valor inicial bem baixo para comparação
		
		# O loop 'for' percorre o dicionário e acha a direção correta
		for vec in directions.keys():
			var dot_product = dir.dot(vec) 
			if dot_product > max_dot:
				max_dot = dot_product
				best_match = directions[vec]
		
		last_direction = best_match
		sprite.play("walk_" + last_direction)
	else:
		sprite.play("idle_" + last_direction)
