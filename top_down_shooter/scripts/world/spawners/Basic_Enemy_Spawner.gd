extends Node2D

@export var active := false
@onready var reattempt_timer : Timer = $Reattempt_Spawn_Timer as Timer
var obstructed = false

func _ready() -> void:
	World.spawn_enemies.connect(_on_spawn_enemy)
	World.remaining_wave_enemy_count_changed.connect(_on_remaining_wave_enemy_count_changed)
	

func _on_spawn_enemy() -> void:
	attempt_enemy_spawn()
		
func _on_remaining_wave_enemy_count_changed() -> void:
	if World.remaining_wave_enemy_count < World.max_wave_enemy_count:
		attempt_enemy_spawn()


func _on_reattempt_spawn_timer_timeout():
	if World.remaining_wave_enemy_count > 0 and World.enemy_count < World.max_enemy_count and active:
		attempt_enemy_spawn()
	else:
		reattempt_timer.stop()

func attempt_enemy_spawn() -> void:
	if !obstructed and World.remaining_wave_enemy_count > 0 and World.enemy_count < World.max_enemy_count and World.total_wave_enemies_spawned < World.max_wave_enemy_count and active:
		var new_enemy = preload("res://scenes/entities/enemies/Enemy.tscn").instantiate()
		new_enemy.global_position = global_position
		get_node("/root/World").add_child(new_enemy)
		
		reattempt_timer.start()


func _on_body_entered(body):
	if body.is_in_group("enemy") or body.is_in_group("player"):
		obstructed = true


func _on_body_exited(body):
	if body.is_in_group("enemy") or body.is_in_group("player"):
		obstructed = false
