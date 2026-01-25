extends CharacterBody2D

@export var speed = 150.0
@export var player: Node2D

func _physics_process(delta):
	if player:
		# 1. Calcula a direção para o player
		var direction = (player.global_position - global_position).normalized()
		
		# 2. Define a velocidade (velocity é uma variável interna do CharacterBody2D)
		velocity = direction * speed
		
		# 3. move_and_slide() usa a 'velocity' para mover o corpo e checar colisões
		move_and_slide()
