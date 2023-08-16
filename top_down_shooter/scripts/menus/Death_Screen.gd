extends Control

@onready var waves_survived : Label = $"CanvasLayer/You Survived/Waves_Survived" as Label
@onready var enemies_killed : Label = $"CanvasLayer/You Killed/Enemies_Killed" as Label
@onready var GM = $"../../"

@onready var button_hover_audio : AudioStreamPlayer2D = $Button_Hover

func _ready() -> void:
	waves_survived.text = str(World.wave) + " waves" if World.wave > 1 else str(World.wave) + " wave"
	enemies_killed.text = str(World.total_kills) + " enemies" if World.total_kills != 1 else str(World.total_kills) + " enemy"
	World.UI.canvas_layer.hide()

func _on_main_menu_button_pressed():
	GM.exit_level()
	Menus.main_menu_selected.emit()
	GM.game_paused = false
	World.kill_all_enemies.emit()
	queue_free()

func _on_main_menu_button_mouse_entered():
	button_hover_audio.play()
