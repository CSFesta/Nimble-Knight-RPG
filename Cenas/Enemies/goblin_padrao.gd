extends CharacterBody2D

@export var speed: float = 40.0

@onready var health = $Health
@onready var sprite = $AnimatedSprite2D

var player: Node2D = null
var last_direction := "front"

var directions = {
	Vector2.DOWN: "front",
	Vector2.UP: "back",
	Vector2.LEFT: "left",
	Vector2.RIGHT: "right"
}

func _ready() -> void:
	health.died.connect(on_died)

func _physics_process(_delta: float) -> void:
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
	else:
		sprite.play("idle_" + last_direction)

func take_damage(amount: int) -> void:
	print("Goblin levou dano:", amount)
	health.take_damage(amount)

func on_died() -> void:
	print("Goblin morreu")
	queue_free()
