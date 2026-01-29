extends Node2D

@export var goblin_scene: PackedScene
@export var spawn_distance: float = 1000.0
@export var max_mobs: int = 20

@onready var timer: Timer = $Timer

var cur_mobs: int = 0

func _ready() -> void:
	if not timer:
		push_error("Spawner ERRO: Timer não encontrado!")
		return

	if not goblin_scene:
		push_error("Spawner ERRO: Goblin Scene NÃO atribuída no Inspector!")
		return

	timer.wait_time = 0.2
	timer.autostart = true
	timer.start()

	print("Spawner iniciado | Máx mobs:", max_mobs)

func _on_timer_timeout() -> void:
	if not goblin_scene:
		return

	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return

	if cur_mobs >= max_mobs:
		return

	spawn_enemy(player.global_position)

func spawn_enemy(player_pos: Vector2) -> void:
	var enemy = goblin_scene.instantiate()

	if not enemy:
		push_error("Falha ao instanciar goblin!")
		return

	var random_dir = Vector2.RIGHT.rotated(randf() * TAU)
	enemy.global_position = player_pos + random_dir * spawn_distance

	get_tree().current_scene.add_child(enemy)

	cur_mobs += 1
	print("Goblin criado | Atuais:", cur_mobs)

	if enemy.has_signal("enemy_died"): #a morte ainda nao esta configurada
		enemy.enemy_died.connect(_on_enemy_died)

func _on_enemy_died() -> void: #ajustar esta com erro
	cur_mobs -= 1
	cur_mobs = max(cur_mobs, 0)
	print("Goblin morreu | Atuais:", cur_mobs)
