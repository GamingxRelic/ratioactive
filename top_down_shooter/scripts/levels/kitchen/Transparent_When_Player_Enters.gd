extends Node2D

func _on_body_entered(body):
	if body.is_in_group("player"):
		modulate.a = 0.4

func _on_body_exited(body):
	if body.is_in_group("player"):
		modulate.a = 1.0
