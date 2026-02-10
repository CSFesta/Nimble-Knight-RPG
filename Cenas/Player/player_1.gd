extends CharacterBody2D

# ---------------- CONST ----------------
const BASE_SPEED := 100.0
const ATTACK_TIME := 0.5
const STRONG_ATTACK_TIME := 0.8

# ---------------- VAR ----------------
var speed := BASE_SPEED

# ---------------- NODES ----------------
@export var body_texture: BodyTexture
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
	health.died.connect(on_died)
	
	# GARANTIA: A hitbox começa totalmente desligada
	hitbox.monitoring = false
	hitbox.monitorable = false 

# ---------------- PHYSICS PROCESS ----------------
func _physics_process(delta: float) -> void:
	# -------- LÓGICA DE ATAQUE --------
	if is_attacking:
		attack_timer -= delta
		if attack_timer <= 0:
			stop_attack() # Função para limpar o estado de ataque
		else:
			# Durante o ataque o player fica parado (opcional)
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

	# TORNA A HITBOX "VISÍVEL" PARA OS GOBLINS
	hitbox.monitorable = true 
	# Opcional: Ativar monitoring se a hitbox precisar detectar algo
	# hitbox.monitoring = true 

func stop_attack() -> void:
	is_attacking = false
	state = "idle"
	# TORNA A HITBOX "INVISÍVEL" NOVAMENTE
	hitbox.monitorable = false 
	# hitbox.monitoring = false

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
	if body_texture:
		body_texture.update_animation(state, velocity)
		
		# AJUSTE DE DIREÇÃO DA HITBOX
		# Faz a hitbox seguir o lado para onde o player está virado
		if velocity.x > 0:
			hitbox.scale.x = 1
		elif velocity.x < 0:
			hitbox.scale.x = -1

# ---------------- DANO E MORTE ----------------

func take_damage(amount: int) -> void:
	if is_guarding:
		# Aqui você poderia adicionar um som de "tink" ou faíscas
		return
	health.take_damage(amount)

func on_died() -> void:
	# Em vez de apenas deletar, você poderia tocar uma animação de morte aqui
	queue_free()
