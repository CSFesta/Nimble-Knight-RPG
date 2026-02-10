extends CharacterBody2D

@export var speed: float = 40.0

@onready var health = $Health
@onready var sprite = $AnimatedSprite2D

var player: Node2D = null
var last_direction := "front"
var is_hurt := false # Nova variável para controlar o estado de dor

var directions = {
	Vector2.DOWN: "front",
	Vector2.UP: "back",
	Vector2.LEFT: "left",
	Vector2.RIGHT: "right"
}

func _ready() -> void:
	health.died.connect(on_died)

func _physics_process(_delta: float) -> void:
	# Se estiver em estado de "dor", não processa movimento nem troca de animação
	if is_hurt:
		return

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
		var max_dot = -2.0
		
		for vec in directions.keys():
			var dot_product = dir.dot(vec)
			if dot_product > max_dot:
				max_dot = dot_product
				best_match = directions[vec]
		
		last_direction = best_match
		sprite.play("walk_" + last_direction)
	else:
		sprite.play("idle_" + last_direction)

# --- SISTEMA DE DANO ATUALIZADO ---

func take_damage(amount: int) -> void:
	if is_hurt: return # Evita múltiplos frames de dano seguidos
	
	print("Goblin levou dano:", amount)
	health.take_damage(amount)
	
	# Se ainda estiver vivo após o dano, toca a animação de "Hurt"
	if health.life > 0:
		play_hurt_animation()

func play_hurt_animation() -> void:
	is_hurt = true
	velocity = Vector2.ZERO # Para o movimento
	sprite.play("hurt_" + last_direction)
	
	# Aguarda a animação acabar ou um tempo fixo (ex: 0.3 segundos)
	await get_tree().create_timer(0.3).timeout
	is_hurt = false

func on_died() -> void:
	print("Goblin morreu e será removido")
	
	# 1. Desativa processamento para evitar que ele continue andando "invisível"
	set_physics_process(false)
	
	# 2. Desativa as colisões (Hurtbox e Corpo)
	$Hurtbox.set_deferred("monitoring", false)
	$Hurtbox.set_deferred("monitorable", false)
	$CollisionShape2D.set_deferred("disabled", true) # Substitua pelo nome do seu CollisionShape do corpo
	
	# 3. Faz sumir visualmente
	visible = false
	
	# 4. Deleta o objeto da memória
	queue_free()
