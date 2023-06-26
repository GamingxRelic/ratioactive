extends Camera2D

func _process(_delta):
	var mouse_pos = get_global_mouse_position()
	
	offset.x = (mouse_pos.x-global_position.x) / get_viewport().size.x*300
	offset.y = (mouse_pos.y-global_position.y) / get_viewport().size.y*150
