extends CharacterBody2D

# ---------------- CONST ----------------
const BASE_SPEED := 75.0
const ATTACK_TIME := 0.5
const STRONG_ATTACK_TIME := 0.8

# ---------------- VAR ----------------
var speed := BASE_SPEED

# ---------------- NODES ----------------
@export var body_texture: BodyTexture

# ---------------- ESTADO ----------------
var state := "idle"
var is_attacking := false
var is_guarding := false
var attack_timer := 0.0

# ---------------- PHYSICS PROCESS ----------------
func _physics_process(delta: float) -> void:
	# -------- ATAQUE --------
	if is_attacking:
		attack_timer -= delta
		if attack_timer <= 0:
			is_attacking = false
			state = "idle"
		else:
			velocity = Vector2.ZERO
			move_and_slide()
			update_visuals()
			return

	# -------- GUARD (TRAVA MOVIMENTO) --------
	if Input.is_action_pressed("guard"):
		start_guard()
		velocity = Vector2.ZERO
		move_and_slide()
		update_visuals()
		return
	else:
		stop_guard()

	# -------- MOVIMENTO NORMAL --------
	var direction := Input.get_vector(
		"ui_left",
		"ui_right",
		"ui_up",
		"ui_down"
	)

	velocity = direction * speed
	move_and_slide()

	state = "walk" if direction != Vector2.ZERO else "idle"

	# -------- ATAQUE --------
	if Input.is_action_just_pressed("attack"):
		start_attack("attack", ATTACK_TIME)
	elif Input.is_action_just_pressed("strong_attack"):
		start_attack("strong_attack", STRONG_ATTACK_TIME)

	update_visuals()


# ---------------- FUNÇÕES ----------------
func start_attack(type: String, duration: float) -> void:
	if is_attacking or is_guarding:
		return
	is_attacking = true
	attack_timer = duration
	state = type


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


func update_visuals() -> void:
	if body_texture:
		body_texture.update_animation(state, velocity)
