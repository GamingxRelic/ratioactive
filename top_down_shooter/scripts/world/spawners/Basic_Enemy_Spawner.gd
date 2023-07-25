extends Node2D

#@onready var spawn_queue : Array = 

func _ready() -> void:
	World.spawn_enemies.connect(_on_spawn_enemy)
	World.enemy_count_changed.connect(_on_enemy_count_changed)

func _on_spawn_enemy() -> void:
	var new_enemy = preload("res://scenes/entities/enemies/Enemy.tscn").instantiate()
	new_enemy.global_position = global_position
	if World.enemy_count != World.max_enemy_count:
		get_node("/root/World").add_child(new_enemy)
	else:
		World.enemy_spawn_queue.append(new_enemy)
		
func _on_enemy_count_changed() -> void:
	if World.enemy_spawn_queue.size() > 0 and World.enemy_count != World.max_enemy_count:
		get_node("/root/World").add_child(World.enemy_spawn_queue.pop_front())
		#get_node("/root/World").call_deferred("add_child", spawn_queue.pop_front())
