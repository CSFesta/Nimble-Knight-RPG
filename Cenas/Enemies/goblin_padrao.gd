extends CharacterBody2D

@export var speed: float = 100.0
var player: Node2D = null 
@onready var sprite = $AnimatedSprite2D 

func _ready() -> void:
	add_to_group("enemies")
	# Busca o player
	player = get_tree().get_first_node_in_group("player")
	
	# --- PRINT DE DEBUG ---
	print("--- DEBUG GOBLIN ---")
	print("Nasci na posição: ", global_position)
	if player:
		print("Alvo (Player) encontrado! Distância: ", global_position.distance_to(player.global_position))
	else:
		print("ERRO: Player não encontrado. Verifique se o Player tem a linha add_to_group('player')")

func _physics_process(_delta: float) -> void:
	if is_instance_valid(player):
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * speed
		move_and_slide()
	else:
		player = get_tree().get_first_node_in_group("player")
		velocity = Vector2.ZERO
