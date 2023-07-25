extends Node2D

class_name level

@onready var anim_player : AnimationPlayer = $AnimationPlayer as AnimationPlayer

var wave := 0
@export var max_enemy_count := 2

func _ready() -> void:
	World.max_enemy_count = max_enemy_count
	
	anim_player.play("reveal_map")
	
	World.connect("next_wave", _on_next_wave)

func _on_next_wave() -> void:
	wave += 1
	World.UI.set_wave_label(wave)
	World.emit_signal("spawn_enemies")

#func _process(_delta) -> void:
#	pass
