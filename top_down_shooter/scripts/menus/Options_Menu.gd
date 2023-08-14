extends Control

func _process(_delta):
	if Input.is_action_just_pressed("pause"):
		_on_back_pressed()

func _on_back_pressed():
	Menus.main_menu_selected.emit()
	queue_free()
