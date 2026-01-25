extends Node2D

@export var goblin_scene: PackedScene # Arraste o goblin_tipo_1.tscn aqui no Inspetor
@export var spawn_distance: float = 1000.0 # Distância do nascimento

@onready var timer = $Timer

func _ready() -> void:
	if timer:
		timer.wait_time = 0.2
		timer.autostart = true
		timer.start()
		print("--- Spawner pronto e Timer iniciado! ---")
	else:
		print("--- ERRO: Nó Timer não encontrado! ---")

# Esta função deve estar conectada ao sinal timeout() do seu Timer
func _on_timer_timeout() -> void:
	var player = get_tree().get_first_node_in_group("player")
	
	if player and goblin_scene:
		spawn_enemy(player.global_position)
	else:
		print("--- Falha no spawn: Player ou Cena do Goblin ausente ---")

func spawn_enemy(player_pos: Vector2) -> void:
	var enemy = goblin_scene.instantiate()
	
	# Calcula posição aleatória ao redor do player
	var random_direction = Vector2.RIGHT.rotated(randf() * TAU)
	var spawn_pos = player_pos + (random_direction * spawn_distance)
	
	enemy.global_position = spawn_pos
	
	# Adiciona ao mundo (cena principal)
	get_tree().current_scene.add_child(enemy)
	print("--- LOG: Goblin criado em: ", spawn_pos, " ---")
