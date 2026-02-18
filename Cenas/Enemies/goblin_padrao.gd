extends CharacterBody2D

@export var speed: float = 40.0

@onready var health = $Health
@onready var sprite = $AnimatedSprite2D
@onready var hitbox = $Hitbox 
@onready var attack_area = $AttackArea

var player: Node2D = null
var last_direction := "front"
var is_hurt := false 
var is_attacking := false 
var can_attack := true # Controla o intervalo entre ataques

var directions = {
	Vector2.DOWN: "front",
	Vector2.UP: "back",
	Vector2.LEFT: "left",
	Vector2.RIGHT: "right"
}

func _ready() -> void:
	# Conexão de segurança caso você não tenha feito pelo editor:
	if not attack_area.body_entered.is_connected(_on_attack_area_body_entered):
		attack_area.body_entered.connect(_on_attack_area_body_entered)
	
	health.died.connect(on_died)
	
	if hitbox:
		hitbox.add_to_group("enemy_attack")

func _physics_process(_delta: float) -> void:
	# Se estiver atacando, levando dano ou morto, fica parado
	if is_hurt or health.life <= 0 or is_attacking:
		velocity = Vector2.ZERO
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
		
		# ATUALIZA A POSIÇÃO DA HITBOX SEMPRE QUE MUDAR A DIREÇÃO
		update_hitbox_position()
	else:
		sprite.play("idle_" + last_direction)

func update_hitbox_position() -> void:
	if not hitbox: return
	
	match last_direction:
		"right":
			# Direita padrão
			hitbox.position = Vector2(18, 0)
			hitbox.rotation_degrees = 0
		"left":
			# Aumentei para -22 para compensar o erro que você notou
			hitbox.position = Vector2(-30, 0)
			hitbox.rotation_degrees = 0
		"front":
			# Baixo padrão
			hitbox.position = Vector2(0, 18)
			hitbox.rotation_degrees = 90
		"back":
			# Aumentei para -25 para subir bem a hitbox no ataque para cima
			hitbox.position = Vector2(0, -40)
			hitbox.rotation_degrees = 90
			
# --- LÓGICA DE ATAQUE ---
func _on_attack_area_body_entered(body: Node2D) -> void:
	# Só inicia se puder atacar, não estiver ocupado e o player for o alvo
	if body.is_in_group("player") and can_attack and not is_attacking and health.life > 0:
		attack()

func attack() -> void:
	if is_attacking or not can_attack: return
	
	is_attacking = true
	can_attack = false
	
	# 1. Toca a animação
	sprite.play("attack_" + last_direction)
	
	# 2. LIGA a hitbox (usando call_deferred para garantir que o motor de física processe)
	hitbox.set_deferred("monitoring", true)
	
	# 3. Espera o tempo do dano (ex: 0.3s ou o tempo total da animação)
	await get_tree().create_timer(0.4).timeout 
	
	# 4. DESLIGA a hitbox (Isso é o que permite que o próximo ataque seja contado como "novo")
	hitbox.set_deferred("monitoring", false)
	
	# 5. Espera o resto do cooldown (para completar os 0.6s)
	await get_tree().create_timer(0.2).timeout
	
	is_attacking = false
	can_attack = true
	_check_for_next_attack()

func _check_for_next_attack() -> void:
	# Verifica todos os corpos dentro da AttackArea agora
	for b in attack_area.get_overlapping_bodies():
		if b.is_in_group("player") and health.life > 0:
			attack()
			break
			
# --- DANO E MORTE ---

func take_damage(amount: int) -> void:
	if is_hurt or health.life <= 0: 
		return 
	
	health.take_damage(amount)
	is_attacking = false # Interrompe o ataque se apanhar
	
	if health.life > 0:
		play_hurt_animation()

func play_hurt_animation() -> void:
	is_hurt = true
	sprite.play("hurt_" + last_direction)
	await get_tree().create_timer(0.333).timeout 
	is_hurt = false

func on_died() -> void:
	set_physics_process(false)
	is_hurt = true 
	sprite.play("death_" + last_direction)
	
	# Desliga todos os sensores
	attack_area.monitoring = false
	if hitbox: hitbox.set_deferred("monitoring", false)
	if has_node("Hurtbox"): $Hurtbox.set_deferred("monitoring", false)
	
	await get_tree().create_timer(0.6).timeout
	queue_free()
