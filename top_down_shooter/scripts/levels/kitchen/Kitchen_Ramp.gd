extends Sprite2D

func _on_buyable_component_player_entered_range():
	material = World.outline

func _on_buyable_component_player_exited_range():
	material = null

func _on_buyable_component_purchased():
	self_modulate.a = 1.0
