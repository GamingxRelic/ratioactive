extends Control

@onready var button_hover_audio : AudioStreamPlayer2D = $Button_Hover

func _on_play_pressed():
	#Menus.levels_menu_selected.emit()
	Menus.level_kitchen.emit()
	queue_free()

func _on_options_pressed():
	Menus.options_menu_selected.emit()
	queue_free()

func _on_exit_pressed():
	get_tree().quit()

func _on_play_mouse_entered():
	button_hover_audio.play()

func _on_options_mouse_entered():
	button_hover_audio.play()

func _on_exit_mouse_entered():
	button_hover_audio.play()
