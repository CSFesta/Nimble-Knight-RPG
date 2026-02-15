extends Area2D

# Valor do dano que o Goblin vai tirar do Player
@export var damage: int = 1

func _ready() -> void:
	# Essencial: Define o grupo para que a Hurtbox do Player reconheça o ataque
	add_to_group("enemy_attack")
	
	# Ativa a detecção da área
	monitoring = true
	monitorable = true
