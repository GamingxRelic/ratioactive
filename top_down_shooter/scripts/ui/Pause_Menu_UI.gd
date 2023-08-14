extends CanvasLayer

@export var GM : GameManager


func _ready() -> void:
	GM.connect("toggle_game_paused", _on_game_manager_toggle_game_paused)

func _on_game_manager_toggle_game_paused(is_paused) -> void:
	if is_paused:
		show()
	else:
		hide()


func _on_resume_button_button_down():
	GM.game_paused = false

func _on_main_menu_button_pressed():
	GM.exit_level()
	Menus.main_menu_selected.emit()
	GM.game_paused = false
	World.kill_all_enemies.emit()
