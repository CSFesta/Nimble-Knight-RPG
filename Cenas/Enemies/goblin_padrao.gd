extends CharacterBody2D

@export var speed: float = 40.0

@onready var health = $Health
@onready var sprite = $AnimatedSprite2D

var player: Node2D = null
var last_direction := "front"
var is_hurt := false 

var directions = {
	Vector2.DOWN: "front",
	Vector2.UP: "back",
	Vector2.LEFT: "left",
	Vector2.RIGHT: "right"
}

func _ready() -> void:
	health.died.connect(on_died)

func _physics_process(_delta: float) -> void:
	# AJUSTE CHAVE: Se estiver em estado de dor ou morto, sai da função imediatamente
	# Isso impede que o velocity seja alterado e que sprite.play() de movimento rode
	if is_hurt or health.life <= 0:
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
	# Esta função só é chamada se NÃO estiver em is_hurt, graças ao check no physics_process
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

# --- SISTEMA DE DANO E MORTE ---

func take_damage(amount: int) -> void:
	if is_hurt or health.life <= 0: 
		return 
	
	health.take_damage(amount)
	
	if health.life > 0:
		play_hurt_animation()

func play_hurt_animation() -> void:
	is_hurt = true
	velocity = Vector2.ZERO # Garante que ele pare de deslizar
	
	sprite.play("hurt_" + last_direction)
	
	# O timer cria uma janela onde o _physics_process será ignorado
	await get_tree().create_timer(0.333).timeout 
	
	is_hurt = false

func on_died() -> void:
	# Para tudo permanentemente
	set_physics_process(false)
	is_hurt = true 
	
	sprite.play("death_" + last_direction)
	
	# Desativa colisões para não travar o player
	$Hurtbox.set_deferred("monitoring", false)
	$Hurtbox.set_deferred("monitorable", false)
	
	if has_node("CollisionShape2D"):
		$CollisionShape2D.set_deferred("disabled", true) 

	# Aguarda o tempo da animação de morte
	await get_tree().create_timer(0.6).timeout
	queue_free()
