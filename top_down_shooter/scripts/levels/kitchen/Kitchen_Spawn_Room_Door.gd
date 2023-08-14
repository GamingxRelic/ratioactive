extends StaticBody2D



func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		self.modulate.a = 0.4


func _on_area_2d_body_exited(body):
	if body.is_in_group("player"):
		self.modulate.a = 1.0
