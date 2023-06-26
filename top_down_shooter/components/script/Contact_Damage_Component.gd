extends Area2D
signal collided
signal exited_collider

func _on_body_entered(body):
#	if body.is_in_group("contact_damage"):
#		if body.is_in_group("player"):
#			collided.emit()
	if body.is_in_group("contact_damage") and body.is_in_group("player"):
		collided.emit()
