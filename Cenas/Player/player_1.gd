extends CharacterBody2D

# ---------------- CONST ----------------
const SPEED = 75.0
const ATTACK_TIME = 0.5
const STRONG_ATTACK_TIME = 0.8

# ---------------- NODES ----------------
@export_category("Objects")
@export var character_texture: CharacterTexture

# ---------------- ESTADO ----------------
var state := "idle"
var is_attacking := false
var is_guarding := false
var attack_timer := 0.0

# ---------------- READY ----------------
func _ready() -> void:
	add_to_group("player")
	global_position = Vector2.ZERO

# ---------------- PHYSICS PROCESS ----------------
func _physics_process(delta: float) -> void:
	# ---------------- ATAQUE ----------------
	if is_attacking:
		attack_timer -= delta
		if attack_timer <= 0:
			is_attacking = false
			state = "idle"
		else:
			velocity = Vector2.ZERO
			move_and_slide()
			character_texture.update_animation(state, velocity)
			return

	# ---------------- GUARDA ----------------
	if is_guarding:
		if not Input.is_action_pressed("guard"):
			is_guarding = false
			state = "idle"
		else:
			velocity = Vector2.ZERO
			move_and_slide()
			character_texture.update_animation(state, velocity)
			return

	# ---------------- MOVIMENTO ----------------
	var direction := Input.get_vector(
		"ui_left",
		"ui_right",
		"ui_up",
		"ui_down"
	)

	velocity = direction * SPEED
	move_and_slide()

	# ---------------- INPUT ----------------
	if Input.is_action_just_pressed("attack"):
		start_attack("attack", ATTACK_TIME)
	elif Input.is_action_just_pressed("strong_attack"):
		start_attack("strong_attack", STRONG_ATTACK_TIME)
	elif Input.is_action_pressed("guard"):
		start_guard()
	else:
		state = "walk" if direction != Vector2.ZERO else "idle"

	# ---------------- ATUALIZA ANIMAÇÃO ----------------
	character_texture.update_animation(state, velocity)

# ---------------- FUNÇÕES ----------------
func start_attack(type: String, duration: float) -> void:
	if is_attacking or is_guarding:
		return
	is_attacking = true
	attack_timer = duration
	state = type

func start_guard() -> void:
	if is_attacking:
		return
	is_guarding = true
	state = "guard"
