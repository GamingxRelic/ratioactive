extends Node2D

class_name GameManager

signal toggle_game_paused

var game_paused : bool = false:
	get:
		return game_paused
	set(value):
		game_paused = value
		get_tree().paused = game_paused
		emit_signal("toggle_game_paused", game_paused)

@onready var levels = $Levels
@onready var menus = $Menus

func _ready():
	World.player_death.connect(_on_player_death)
	Menus.main_menu_selected.connect(_on_main_menu_selected)
	Menus.levels_menu_selected.connect(_on_levels_menu_selected)
	Menus.options_menu_selected.connect(_on_options_menu_selected)
	Menus.level_test.connect(_on_level_test)
	Menus.level_kitchen.connect(_on_level_kitchen)

func _process(_delta) -> void:
	if Input.is_action_just_pressed("pause") and World.game_running:
		game_paused = !game_paused

func exit_level() -> void:
	if levels.get_child_count() > 0:
		levels.get_child(0).queue_free()
	World.game_running = false
	World.reset()
	PlayerGun.reset()
	

func _on_player_death() -> void:
	game_paused = true

func _on_main_menu_selected() -> void:
	var menu = preload("res://scenes/menus/Main_Menu.tscn").instantiate()
	menus.add_child(menu)

func _on_levels_menu_selected() -> void:
	var menu = preload("res://scenes/menus/Levels_Menu.tscn").instantiate()
	menus.add_child(menu)
	
func _on_options_menu_selected() -> void:
	var menu = preload("res://scenes/menus/Options_Menu.tscn").instantiate()
	menus.add_child(menu)

func _on_level_test() -> void:
	var lvl = preload("res://scenes/levels/level_test.tscn").instantiate()
	levels.add_child(lvl)
	
func _on_level_kitchen() -> void:
	var lvl = preload("res://scenes/levels/Level_Kitchen.tscn").instantiate()
	levels.add_child(lvl)
	
## Menus
#signal main_menu_selected
#signal levels_menu_selected
#
## Levels
#signal level_test
#signal level_kitchen
