extends Control

func _process(_delta):
	if Input.is_action_just_pressed("pause"):
		_on_back_pressed()


func _on_back_pressed():
	Menus.main_menu_selected.emit()
	queue_free()

# Levels
func _on_test_level_pressed():
	Menus.level_test.emit()
	queue_free()

func _on_kitchen_level_pressed():
	Menus.level_kitchen.emit()
	queue_free()
