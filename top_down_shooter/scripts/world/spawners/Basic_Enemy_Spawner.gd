extends Node2D

func _ready() -> void:
	World.spawn_enemies.connect(spawn_enemy)

func spawn_enemy() -> void:
	var new_enemy = preload("res://scenes/entities/enemies/Enemy.tscn").instantiate()
	new_enemy.global_position = global_position
	get_node("/root/World").add_child(new_enemy)
