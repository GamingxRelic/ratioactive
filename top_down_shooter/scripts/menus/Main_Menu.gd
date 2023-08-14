extends Control


func _on_play_pressed():
	Menus.levels_menu_selected.emit()
	queue_free()


func _on_options_pressed():
	Menus.options_menu_selected.emit()
	queue_free()


func _on_exit_pressed():
	get_tree().quit()
