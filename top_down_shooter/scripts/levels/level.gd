extends Node2D

@onready var yellow_outline = preload("res://assets/shaders/yellow_outline.tres")
@onready var anim_player : AnimationPlayer = $AnimationPlayer as AnimationPlayer

func _ready() -> void:
	#yellow_outline = preload("res://assets/shaders/yellow_outline.tres")
	anim_player.play("reveal_map")

func _process(_delta) -> void:
	if World.pickup_queue.size() != 0:
		World.pickup_queue[0].sprite.material = yellow_outline
