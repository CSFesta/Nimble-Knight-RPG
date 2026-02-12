extends CharacterBody2D

# ---------------- CONST ----------------
const BASE_SPEED := 100.0
const ATTACK_TIME := 0.5
const STRONG_ATTACK_TIME := 0.8

# ---------------- VAR ----------------
var speed := BASE_SPEED

# ---------------- NODES ----------------
@export var body_texture: BodyTexture # Certifique-se de arrastar o BodySprite para cá no Inspector
@onready var health = $Health
@onready var hitbox: Area2D = $Hitbox
@onready var hitbox_collision: CollisionShape2D = $Hitbox/collisionDamage

# ---------------- ESTADO ----------------
var state := "idle"
var is_attacking := false
var is_guarding := false
var attack_timer := 0.0

# ---------------- READY ----------------
func _ready() -> void:
	add_to_group("player")
	
	# Conexão segura do sinal de morte
	if not health.died.is_connected(on_died):
		health.died.connect(on_died)
	
	# Garante que a hitbox comece desligada
	hitbox.monitoring = false
	hitbox.monitorable = false
	
	# Fallback caso a exportação falhe no Inspector
	if body_texture == null:
		body_texture = $BodySprite

# ---------------- PHYSICS PROCESS ----------------
func _physics_process(delta: float) -> void:
	# -------- LÓGICA DE ATAQUE (CONGELA MOVIMENTO) --------
	if is_attacking:
		attack_timer -= delta
		if attack_timer <= 0:
			stop_attack()
		else:
			velocity = Vector2.ZERO
			move_and_slide()
			update_visuals()
			return

	# -------- LÓGICA DE DEFESA (GUARD) --------
	if Input.is_action_pressed("guard"):
		start_guard()
		velocity = Vector2.ZERO
		move_and_slide()
		update_visuals()
		return
	else:
		stop_guard()

	# -------- MOVIMENTO PADRÃO --------
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * speed
	move_and_slide()

	state = "walk" if direction != Vector2.ZERO else "idle"

	# -------- INPUT DE ATAQUE --------
	if Input.is_action_just_pressed("attack"):
		start_attack("attack", ATTACK_TIME)
	elif Input.is_action_just_pressed("strong_attack"):
		start_attack("strong_attack", STRONG_ATTACK_TIME)

	update_visuals()

# ---------------- FUNÇÕES DE COMBATE ----------------

func start_attack(type: String, duration: float) -> void:
	if is_attacking or is_guarding:
		return

	is_attacking = true
	attack_timer = duration
	state = type

	# Ativa a detecção de colisão de forma segura
	hitbox.set_deferred("monitoring", true)
	hitbox.set_deferred("monitorable", true)

func stop_attack() -> void:
	is_attacking = false
	state = "idle"
	# Desativa a detecção de colisão
	hitbox.set_deferred("monitoring", false)
	hitbox.set_deferred("monitorable", false)

func start_guard() -> void:
	if is_guarding:
		return
	is_guarding = true
	state = "guard"

func stop_guard() -> void:
	if not is_guarding:
		return
	is_guarding = false
	state = "idle"

# ---------------- VISUAIS ----------------

func update_visuals() -> void:
	if body_texture == null:
		return
		
	# 1. Atualiza animação e flip_h do Sprite
	body_texture.update_animation(state, velocity)
	
	# 2. Sincroniza a posição da Hitbox com o olhar do Sprite
	if body_texture.flip_h:
		# Se o sprite virou para a esquerda, inverte a escala da área de ataque
		hitbox.scale = Vector2(-1, 1)
	else:
		# Caso contrário, escala padrão (direita)
		hitbox.scale = Vector2(1, 1)

# ---------------- DANO E MORTE ----------------

func take_damage(amount: int) -> void:
	if is_guarding:
		return
	health.take_damage(amount)

func on_died() -> void:
	queue_free()
