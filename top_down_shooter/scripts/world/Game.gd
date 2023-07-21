extends Node2D

var yellow_outline #= preload("res://assets/shaders/yellow_outline.tres")

func _ready() -> void:
	yellow_outline = preload("res://assets/shaders/yellow_outline.tres")

func _process(_delta) -> void:
	if World.pickup_queue.size() != 0:
		World.pickup_queue[0].sprite.material = yellow_outline
