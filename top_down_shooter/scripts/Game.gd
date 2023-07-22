extends Node2D

class_name GameManager

signal toggle_game_paused

var game_paused : bool = false:
	get:
		return game_paused
	set(value):
		game_paused = value
		get_tree().paused = game_paused
		emit_signal("toggle_game_paused", game_paused)

@onready var levels = $Levels

func _process(_delta) -> void:
	if Input.is_action_just_pressed("pause"):
		game_paused = !game_paused
