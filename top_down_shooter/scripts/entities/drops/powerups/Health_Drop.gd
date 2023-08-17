extends Area2D

@onready var anim := $AnimationPlayer

func _ready() -> void:
	anim.play("hovering")

func _on_body_entered(body) -> void:
	if body.is_in_group("player") and World.player_hp < World.player_max_hp:
		World.player.heal()
		queue_free()
