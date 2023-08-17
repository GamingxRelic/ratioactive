extends Area2D

@onready var anim := $AnimationPlayer

func _ready() -> void:
	anim.play("rotate")

func _on_body_entered(body) -> void:
	if body.is_in_group("player"):
		PlayerGun.fill_all_ammo()
		queue_free()
