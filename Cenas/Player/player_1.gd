extends CharacterBody2D

# ---------------- CONST ----------------
const SPEED = 150.0
const ATTACK_TIME = 0.5
const STRONG_ATTACK_TIME = 0.8

const MAX_SHIELD_ENERGY = 3.0 #ajustar nao está 100%
const SHIELD_RECOVERY_RATE = 1.0
# adicionar esquema de niveis do player
# adicionar dano do player
# criar estatisticas pro player (kills, deaths, lvl)
# criar a possibilidade de aumentar os níveis do player

# ---------------- NODES ----------------
#está onready, pois objetos com $ só podem ser instanciados apartir do início do jogo
@onready var anim_player: AnimatedSprite2D = $AnimatedSprite2D

# ---------------- ESTADO ----------------
var state := "idle"
var is_attacking := false
var attack_timer := 0.0
var is_guarding := false
var shield_energy := MAX_SHIELD_ENERGY

# ---------------- READY ----------------
func _ready() -> void:

	add_to_group("player") #spawner localiza o player
	global_position = Vector2(0, 0) #player está na posição normal (0 , 0)
	print("Player inicializado no grupo: ", get_groups())

# ---------------- PHYSICS PROCESS ----------------
func _physics_process(delta: float) -> void:
	#usando physics_process, o valor de delta é constante
	
	# Lógica de Ataque
	if is_attacking:
		attack_timer -= delta
		if attack_timer <= 0:
			is_attacking = false
			state = "idle"
			anim_player.play("idle")
		else:
			velocity = Vector2.ZERO #personagem não se move ao atacar
			move_and_slide()
			return

	# Lógica de Escudo
	if is_guarding: 
		# alterar a logica do escudo: 
		# criar uma faixa verde quando o escudo estiver disponivel
		# após o escudo for usado ele fica azul, para simular o carregando / recuperação para utilizar o escudo novamente
		# uso máximo do escudo: 3 segundos, tempo de recuperação é equivalente ao tempo de uso
		if not Input.is_action_pressed("guard") or shield_energy <= 0:
			is_guarding = false
			state = "idle"
			anim_player.play("idle")
		else:
			shield_energy -= delta
			velocity = Vector2.ZERO
			move_and_slide()
			return

	# Movimentação Base
	var direction: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * SPEED
	move_and_slide()

	# Flip do Sprite (movimentação com animação)
	if direction.x < 0:
		anim_player.flip_h = true
	elif direction.x > 0:
		anim_player.flip_h = false

	# Verificação de Inputs
	if Input.is_action_just_pressed("attack"):
		start_attack("attack", ATTACK_TIME)
		# verificar se o ataque está atingindo algum inimigo
		# Ou talvez seja melhor o inimigo verificar se acertou o próprio body (analise)
	elif Input.is_action_just_pressed("strong_attack"):
		start_attack("strong_attack", STRONG_ATTACK_TIME)
		# verificar também se está atacando o inimigo, procurar melhor forma
	elif Input.is_action_pressed("guard") and shield_energy > 0:
		start_guard()
		# atualizar a nova lógica do guard
	else:
		update_movement_animation(direction)
		

	# Recuperação de Energia do Escudo
	if not is_guarding and shield_energy < MAX_SHIELD_ENERGY: #isso deve ser ajustado com a nova logica do escudo
		shield_energy += SHIELD_RECOVERY_RATE * delta
		shield_energy = min(shield_energy, MAX_SHIELD_ENERGY)

# ---------------- FUNÇÕES ----------------
func start_attack(type: String, duration: float) -> void:
	if is_attacking or is_guarding:
		return
	is_attacking = true
	attack_timer = duration
	state = type
	anim_player.play(type)

func start_guard() -> void:
	if is_attacking:
		return
	is_guarding = true
	state = "guard"
	anim_player.play("guard")

func update_movement_animation(direction: Vector2) -> void:
	if direction != Vector2.ZERO:
		state = "walk"
		anim_player.play("walk")
	else:
		state = "idle"
		anim_player.play("idle")
