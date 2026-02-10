extends Node2D

@export var goblin_scene: PackedScene
@export var spawn_distance: float = 100.0
@export var max_mobs: int = 5

@onready var timer: Timer = $Timer

var cur_mobs := 0

func _ready() -> void:
	if not goblin_scene:
		push_error("Spawner: Goblin Scene não atribuída!")
		return

	timer.wait_time = 0.5
	timer.start()

func _on_timer_timeout() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return

	if cur_mobs >= max_mobs:
		return

	spawn_enemy(player.global_position)

func spawn_enemy(player_pos: Vector2) -> void:
	var enemy = goblin_scene.instantiate()
	if not enemy:
		return

	var random_dir = Vector2.RIGHT.rotated(randf() * TAU)
	enemy.global_position = player_pos + random_dir * spawn_distance

	get_tree().current_scene.add_child(enemy)
	cur_mobs += 1

	if enemy.has_node("Health"):
		enemy.get_node("Health").died.connect(_on_enemy_died)

func _on_enemy_died() -> void:
	cur_mobs = max(cur_mobs - 1, 0)
